library ieee;
use ieee.std_logic_1164.all;
library grlib, techmap;
use grlib.amba.all;
use grlib.amba.all;
use grlib.stdlib.all;
use techmap.gencomp.all;
use techmap.allclkgen.all;
library enclustra;
use enclustra.fx3_pkg.all;
--use work.config.all;

entity fx3bridge is
  generic (
    tech         : integer range 0 to NTECH := inferred;
    fragmentsize : integer := 512; -- bytes
    iflen        : integer := 32 );
  
  port (    -- clock / reset interface
    Clk_sys			: in	std_logic;
    Clk_fx3			: in	std_logic;
    RESET_N			: in	std_logic; 

    dbg_out                     : out fx3bridge_out;
    
    -- sys clock domain:
    avl_data                    : in    std_logic_vector(31 downto 0);
    avl_ready                   : out   std_logic;
    avl_valid                   : in    std_logic;
    avl_endofpacket             : in    std_logic;
    avl_startofpacket           : in    std_logic;
  
    -- fx3 clock domain: EZ-USB FX3 slave FIFO interface
    FX3_SlRd_N			: out	std_logic;
    FX3_SlWr_N			: out	std_logic;
    FX3_SlOe_N                  : out	std_logic;
    FX3_SlTri_N                 : out	std_logic;
    FX3_Pktend_N		: out	std_logic;
    FX3_A1			: out	std_logic;
    FX3_DQ_o			: out	std_logic_vector(iflen-1 downto 0);
    FX3_DQ_i			: in	std_logic_vector(iflen-1 downto 0);
    FX3_FlagA			: in	std_logic;
    FX3_FlagB			: in	std_logic
    );
end;

architecture rtl of fx3bridge is

constant gpif_fragmentsize : positive  := fragmentsize/(iflen/8);
  
type regs_sys is record
  avl_ready     : std_logic;
  avl_data      : std_logic_vector(31 downto 0);
  tohost_fifo_write : std_logic;
  rcnt          : std_logic_vector(31 downto 0);
  tcnt          : std_logic_vector(31 downto 0);
end record;

type fx3_states is (fx3_idle, fx3_check_write, fx3_check_read, fx3_read, fx3_write, fx3_write_const);
constant refresh_Cycles	: integer  := 6; -- Required refresh cycles after address change
constant delayCounterSz : integer  := 4;


type regs_fx3 is record
  state         :  fx3_states;
  rcnt          :  std_logic_vector(31 downto 0);
  cnt           :  std_logic_vector(31 downto 0);
  delay         :  std_logic_vector(delayCounterSz-1 downto 0);

  FX3_SlRd_N    :  std_logic;
  FX3_SlWr_N	:  std_logic;
  FX3_SlOe_N    :  std_logic;
  FX3_SlTri_N   :  std_logic;
  FX3_Pktend_N	:  std_logic;
  FX3_A1        :  std_logic;
  FX3_DQ_o      :  std_logic_vector(iflen-1 downto 0);

  tohost_fifo_read      : std_logic;      

  dbg_out_state           :  std_logic_vector(3 downto 0);
  
end record;

signal rsys, rsysin     : regs_sys;
signal rfx3, rfx3in     : regs_fx3;
signal rst : std_logic;

signal tofpga_fifo_freeforpacket  : std_logic;

constant	RdPort_c		:std_logic_vector(1 downto 0) := "00";
constant	WrPort_c		:std_logic_vector(1 downto 0) := "10";

constant tohost_dbits : integer := iflen;
signal tohost_fifo_read      : std_logic;
signal tohost_fifo_dataout   : std_logic_vector(tohost_dbits-1 downto 0);
signal tohost_fifo_haspacket : std_logic;
signal tohost_fifo_empty     : std_logic;
      
signal tohost_fifo_write     : std_logic;
signal tohost_fifo_datain    : std_logic_vector(tohost_dbits-1 downto 0);
signal tohost_fifo_isfull    : std_logic;


begin
  
  rst <= RESET_N;
  
  ----------------------------------
  -- System clock domain -----------
  ----------------------------------
  
  sys : process(rst, rsys,
                tohost_fifo_isfull,
                avl_data, avl_valid, avl_endofpacket, avl_startofpacket )
    
  variable vsys : regs_sys;
  begin
    
    vsys := rsys;

    vsys.avl_ready  := not tohost_fifo_isfull;
    vsys.avl_data   := avl_data;
    vsys.tohost_fifo_write := (not tohost_fifo_isfull) and avl_valid;
    
    
    -- reset operation
    if (rst = '0') then
      vsys.rcnt := (others => '0'); vsys.tcnt := (others => '0');
    end if;
    
    -- update registers
    rsysin <= vsys;

    avl_ready          <= vsys.avl_ready;
    tohost_fifo_datain <= vsys.avl_data;
    tohost_fifo_write  <= vsys.tohost_fifo_write;

    dbg_out.tohost_fifo_isfull <= tohost_fifo_isfull;
    
  end process;
  
  ----------------------------------
  -- Fx3 100mhz clock domain -------
  ----------------------------------
  
  fx3 : process(rst, rfx3,
                tohost_fifo_read, tohost_fifo_dataout, tohost_fifo_haspacket, tohost_fifo_empty,
                FX3_FlagA, FX3_FlagB )
    
  variable vfx3 : regs_fx3;
  begin
    
    vfx3 := rfx3;
    vfx3.cnt := (others => '0');
    vfx3.FX3_SlOe_N   := '1';
    vfx3.FX3_SlTri_N  := '1';
    vfx3.FX3_SlRd_N   := '1';
    vfx3.FX3_SlWr_N   := '1';
    vfx3.FX3_Pktend_N := '1';
    vfx3.tohost_fifo_read := '0';
    
    vfx3.dbg_out_state := (others => '0');
    
    case rfx3.state is
      when fx3_idle =>
        
        vfx3.state := fx3_check_write; -- fx3_write_const; --fx3_check_write;
        
        
      --when fx3_check_read =>
      --  if (rfx3.cnt = conv_std_logic_vector(refresh_Cycles, rfx3.cnt'length)) then
      --    if (FX3_FlagA = '1') and (tofpga_fifo_freeforpacket = '1')  then
      --      vfx3.state := fx3_read;
      --    else
      --      vfx3.state := fx3_check_write;
      --    end if;
      --  else
      --    vfx3.cnt := rfx3.cnt + 1;
      --  end if;
      --when fx3_read =>
      --  -- todo: FX3 -> fpga


        
      when fx3_check_write =>
        vfx3.dbg_out_state := "0001";

        
        vfx3.FX3_A1 := WrPort_c(1);
        vfx3.FX3_SlTri_N := '0';
        if (rfx3.cnt = conv_std_logic_vector(refresh_Cycles, rfx3.cnt'length)) then
          if (tohost_fifo_haspacket = '1') and (FX3_FlagB = '1')  then
            vfx3.state := fx3_write;
          else
            vfx3.state := fx3_idle; --fx3_check_read;
          end if;
        else
          vfx3.cnt := rfx3.cnt + 1;
        end if;
      when fx3_write =>         -- fpga -> Fx3
        vfx3.dbg_out_state := "0010";
        
        if (rfx3.cnt = conv_std_logic_vector(gpif_fragmentsize-1, rfx3.cnt'length)) then
          vfx3.state := fx3_check_write;
          --vfx3.FX3_Pktend_N := '0';
        else
          vfx3.cnt := rfx3.cnt + 1;
        end if;
        vfx3.tohost_fifo_read := '1';
        vfx3.FX3_SlWr_N := '0';
        vfx3.FX3_SlTri_N := '0';
        vfx3.FX3_DQ_o := tohost_fifo_dataout;



      when fx3_write_const =>         -- fpga -> Fx3
        vfx3.dbg_out_state := "0011";
        
        vfx3.tohost_fifo_read := '1';
        if (FX3_FlagB = '1') then
          vfx3.FX3_SlWr_N := '0';
          vfx3.FX3_SlTri_N := '0';
        end if;
        vfx3.FX3_DQ_o := tohost_fifo_dataout;


        
      when others => vfx3.state := fx3_idle;
    end case; 
    
    -- reset operation
    if (rst = '0') then
      vfx3.rcnt := (others => '0'); vfx3.cnt := (others => '0');
      vfx3.FX3_SlRd_N := '1';  
      vfx3.FX3_SlWr_N := '1';  
      vfx3.FX3_SlOe_N := '1';  
      vfx3.FX3_SlTri_N := '1'; 
      vfx3.FX3_Pktend_N := '1';
      vfx3.FX3_A1 := '0';
      vfx3.state := fx3_idle;
    end if;
    
    -- update registers
    rfx3in <= vfx3;

    FX3_SlRd_N   <= rfx3.FX3_SlRd_N;
    FX3_SlWr_N	 <= rfx3.FX3_SlWr_N;
    FX3_SlOe_N   <= rfx3.FX3_SlOe_N;
    FX3_SlTri_N  <= rfx3.FX3_SlTri_N;
    FX3_Pktend_N <= rfx3.FX3_Pktend_N;
    FX3_A1       <= rfx3.FX3_A1;      
    FX3_DQ_o     <= rfx3.FX3_DQ_o;      
    
    tohost_fifo_read <= vfx3.tohost_fifo_read;
    
    dbg_out.state <= vfx3.dbg_out_state;
    dbg_out.tohost_fifo_haspacket <= tohost_fifo_haspacket;
    dbg_out.cnt <= rfx3.cnt;
    
  end process;
  
  ----------------------------------
  -- generate registers ------------
  ----------------------------------
  
  regssys : process(Clk_sys)
  begin
    if rising_edge(Clk_sys) then
      rsys <= rsysin;
    end if;
  end process;
  
  regsfx3 : process(Clk_fx3)
  begin
    if rising_edge(Clk_fx3) then
      rfx3 <= rfx3in;
    end if;
  end process;

  tohost: fx3fifo
  generic map (
      tech => tech,
      packetsz => gpif_fragmentsize,
      dbits => tohost_dbits
      )
  port map (
      -- clock / reset interface
      Clk_w	  => Clk_sys,
      Clk_r       => Clk_fx3,
      RESET_N	  => RESET_N,
      -- read domain:
      fifo_read      => tohost_fifo_read,      
      fifo_dataout   => tohost_fifo_dataout,   
      fifo_haspacket => tohost_fifo_haspacket, 
      fifo_empty     => tohost_fifo_empty,     
      -- write domain:                       
      fifo_write     => tohost_fifo_write,     
      fifo_datain    => tohost_fifo_datain,    
      fifo_isfull    => tohost_fifo_isfull    
  );

  
end;

