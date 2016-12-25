------------------------------------------------------------------------------
----                                                                      ----
----  Single Port RAM that maps to a Xilinx BRAM                          ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  This is a program+data memory for the ZPU. It maps to a Xilinx BRAM ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2008 Instituto Nacional de Tecnologa Industrial       ----
----                                                                      ----
---- Distributed under the BSD license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      SinglePortRAM(Xilinx) (Entity and architecture)    ----
---- File name:        rom_s.in.vhdl (template used)                      ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SinglePortRAM is
   generic(
      WORD_SIZE    : integer:=32;  -- Word Size 16/32
      BYTE_BITS    : integer:=2;   -- Bits used to address bytes
      BRAM_W       : integer:=15); -- Address Width
   port(
      clk_i   : in  std_logic;
      we_i    : in  std_logic;
      re_i    : in  std_logic;
      addr_i  : in  unsigned(BRAM_W-1 downto BYTE_BITS);
      write_i : in  unsigned(WORD_SIZE-1 downto 0);
      read_o  : out unsigned(WORD_SIZE-1 downto 0);
      busy_o  : out std_logic);
end entity SinglePortRAM;

--library synplify;
architecture rtl of SinglePortRAM is
   type ram_type is array(natural range 0 to ((2**BRAM_W)/4)-1) of unsigned(WORD_SIZE-1 downto 0);
   signal addr_r  : unsigned(BRAM_W-1 downto BYTE_BITS);
   attribute syn_ramstyle : string;
   attribute syn_ramstyle of addr_r : signal is "block_ram";

   signal ram : ram_type :=
     (
     0 => x"0b0b0b0b",
     1 => x"82700b0b",
     2 => x"0b95d00c",
     3 => x"3a0b0b0b",
     4 => x"93990400",
     5 => x"00000000",
     6 => x"00000000",
     7 => x"00000000",
     8 => x"80088408",
     9 => x"88080b0b",
    10 => x"0b93d92d",
    11 => x"880c840c",
    12 => x"800c0400",
    13 => x"00000000",
    14 => x"00000000",
    15 => x"00000000",
    16 => x"71fd0608",
    17 => x"72830609",
    18 => x"81058205",
    19 => x"832b2a83",
    20 => x"ffff0652",
    21 => x"04000000",
    22 => x"00000000",
    23 => x"00000000",
    24 => x"71fd0608",
    25 => x"83ffff73",
    26 => x"83060981",
    27 => x"05820583",
    28 => x"2b2b0906",
    29 => x"7383ffff",
    30 => x"0b0b0b0b",
    31 => x"83a70400",
    32 => x"72098105",
    33 => x"72057373",
    34 => x"09060906",
    35 => x"73097306",
    36 => x"070a8106",
    37 => x"53510400",
    38 => x"00000000",
    39 => x"00000000",
    40 => x"72722473",
    41 => x"732e0753",
    42 => x"51040000",
    43 => x"00000000",
    44 => x"00000000",
    45 => x"00000000",
    46 => x"00000000",
    47 => x"00000000",
    48 => x"71737109",
    49 => x"71068106",
    50 => x"30720a10",
    51 => x"0a720a10",
    52 => x"0a31050a",
    53 => x"81065151",
    54 => x"53510400",
    55 => x"00000000",
    56 => x"72722673",
    57 => x"732e0753",
    58 => x"51040000",
    59 => x"00000000",
    60 => x"00000000",
    61 => x"00000000",
    62 => x"00000000",
    63 => x"00000000",
    64 => x"00000000",
    65 => x"00000000",
    66 => x"00000000",
    67 => x"00000000",
    68 => x"00000000",
    69 => x"00000000",
    70 => x"00000000",
    71 => x"00000000",
    72 => x"0b0b0b88",
    73 => x"c3040000",
    74 => x"00000000",
    75 => x"00000000",
    76 => x"00000000",
    77 => x"00000000",
    78 => x"00000000",
    79 => x"00000000",
    80 => x"720a722b",
    81 => x"0a535104",
    82 => x"00000000",
    83 => x"00000000",
    84 => x"00000000",
    85 => x"00000000",
    86 => x"00000000",
    87 => x"00000000",
    88 => x"72729f06",
    89 => x"0981050b",
    90 => x"0b0b88a6",
    91 => x"05040000",
    92 => x"00000000",
    93 => x"00000000",
    94 => x"00000000",
    95 => x"00000000",
    96 => x"72722aff",
    97 => x"739f062a",
    98 => x"0974090a",
    99 => x"8106ff05",
   100 => x"06075351",
   101 => x"04000000",
   102 => x"00000000",
   103 => x"00000000",
   104 => x"71715351",
   105 => x"020d0406",
   106 => x"73830609",
   107 => x"81058205",
   108 => x"832b0b2b",
   109 => x"0772fc06",
   110 => x"0c515104",
   111 => x"00000000",
   112 => x"72098105",
   113 => x"72050970",
   114 => x"81050906",
   115 => x"0a810653",
   116 => x"51040000",
   117 => x"00000000",
   118 => x"00000000",
   119 => x"00000000",
   120 => x"72098105",
   121 => x"72050970",
   122 => x"81050906",
   123 => x"0a098106",
   124 => x"53510400",
   125 => x"00000000",
   126 => x"00000000",
   127 => x"00000000",
   128 => x"71098105",
   129 => x"52040000",
   130 => x"00000000",
   131 => x"00000000",
   132 => x"00000000",
   133 => x"00000000",
   134 => x"00000000",
   135 => x"00000000",
   136 => x"72720981",
   137 => x"05055351",
   138 => x"04000000",
   139 => x"00000000",
   140 => x"00000000",
   141 => x"00000000",
   142 => x"00000000",
   143 => x"00000000",
   144 => x"72097206",
   145 => x"73730906",
   146 => x"07535104",
   147 => x"00000000",
   148 => x"00000000",
   149 => x"00000000",
   150 => x"00000000",
   151 => x"00000000",
   152 => x"71fc0608",
   153 => x"72830609",
   154 => x"81058305",
   155 => x"1010102a",
   156 => x"81ff0652",
   157 => x"04000000",
   158 => x"00000000",
   159 => x"00000000",
   160 => x"71fc0608",
   161 => x"0b0b0b95",
   162 => x"bc738306",
   163 => x"10100508",
   164 => x"060b0b0b",
   165 => x"88a90400",
   166 => x"00000000",
   167 => x"00000000",
   168 => x"80088408",
   169 => x"88087575",
   170 => x"0b0b0b8e",
   171 => x"842d5050",
   172 => x"80085688",
   173 => x"0c840c80",
   174 => x"0c510400",
   175 => x"00000000",
   176 => x"80088408",
   177 => x"88087575",
   178 => x"0b0b0b8f",
   179 => x"b62d5050",
   180 => x"80085688",
   181 => x"0c840c80",
   182 => x"0c510400",
   183 => x"00000000",
   184 => x"72097081",
   185 => x"0509060a",
   186 => x"8106ff05",
   187 => x"70547106",
   188 => x"73097274",
   189 => x"05ff0506",
   190 => x"07515151",
   191 => x"04000000",
   192 => x"72097081",
   193 => x"0509060a",
   194 => x"098106ff",
   195 => x"05705471",
   196 => x"06730972",
   197 => x"7405ff05",
   198 => x"06075151",
   199 => x"51040000",
   200 => x"05ff0504",
   201 => x"00000000",
   202 => x"00000000",
   203 => x"00000000",
   204 => x"00000000",
   205 => x"00000000",
   206 => x"00000000",
   207 => x"00000000",
   208 => x"810b0b0b",
   209 => x"0b95cc0c",
   210 => x"51040000",
   211 => x"00000000",
   212 => x"00000000",
   213 => x"00000000",
   214 => x"00000000",
   215 => x"00000000",
   216 => x"71810552",
   217 => x"04000000",
   218 => x"00000000",
   219 => x"00000000",
   220 => x"00000000",
   221 => x"00000000",
   222 => x"00000000",
   223 => x"00000000",
   224 => x"00000000",
   225 => x"00000000",
   226 => x"00000000",
   227 => x"00000000",
   228 => x"00000000",
   229 => x"00000000",
   230 => x"00000000",
   231 => x"00000000",
   232 => x"02840572",
   233 => x"10100552",
   234 => x"04000000",
   235 => x"00000000",
   236 => x"00000000",
   237 => x"00000000",
   238 => x"00000000",
   239 => x"00000000",
   240 => x"00000000",
   241 => x"00000000",
   242 => x"00000000",
   243 => x"00000000",
   244 => x"00000000",
   245 => x"00000000",
   246 => x"00000000",
   247 => x"00000000",
   248 => x"717105ff",
   249 => x"05715351",
   250 => x"020d0400",
   251 => x"00000000",
   252 => x"00000000",
   253 => x"00000000",
   254 => x"00000000",
   255 => x"00000000",
   256 => x"818e3f8c",
   257 => x"f93f0410",
   258 => x"10101010",
   259 => x"10101010",
   260 => x"10101010",
   261 => x"10101010",
   262 => x"10101010",
   263 => x"10101010",
   264 => x"10101010",
   265 => x"10105351",
   266 => x"047381ff",
   267 => x"06738306",
   268 => x"09810583",
   269 => x"05101010",
   270 => x"2b0772fc",
   271 => x"060c5151",
   272 => x"043c0472",
   273 => x"72807281",
   274 => x"06ff0509",
   275 => x"72060571",
   276 => x"1052720a",
   277 => x"100a5372",
   278 => x"ed385151",
   279 => x"535104ff",
   280 => x"3d0d9cfc",
   281 => x"335170a3",
   282 => x"3895d808",
   283 => x"70085252",
   284 => x"70802e92",
   285 => x"38841295",
   286 => x"d80c702d",
   287 => x"95d80870",
   288 => x"08525270",
   289 => x"f038810b",
   290 => x"9cfc3483",
   291 => x"3d0d0404",
   292 => x"803d0d0b",
   293 => x"0b0b9cf4",
   294 => x"08802e8e",
   295 => x"380b0b0b",
   296 => x"0b800b80",
   297 => x"2e098106",
   298 => x"8538823d",
   299 => x"0d040b0b",
   300 => x"0b9cf451",
   301 => x"0b0b0bf6",
   302 => x"c73f823d",
   303 => x"0d0404ff",
   304 => x"3d0d95dc",
   305 => x"08527108",
   306 => x"70882a81",
   307 => x"32708106",
   308 => x"51515170",
   309 => x"f1387372",
   310 => x"0c833d0d",
   311 => x"04fd3d0d",
   312 => x"95dc0854",
   313 => x"84140870",
   314 => x"882a7081",
   315 => x"06515353",
   316 => x"71802ef0",
   317 => x"387281ff",
   318 => x"06527180",
   319 => x"2e9238ba",
   320 => x"51ffbc3f",
   321 => x"7151ffb7",
   322 => x"3f8a51ff",
   323 => x"b23fd139",
   324 => x"71800c85",
   325 => x"3d0d04fe",
   326 => x"3d0d9d80",
   327 => x"08538413",
   328 => x"0870882a",
   329 => x"70810651",
   330 => x"52527080",
   331 => x"2ef03871",
   332 => x"81ff0680",
   333 => x"0c843d0d",
   334 => x"04ff3d0d",
   335 => x"9d800852",
   336 => x"71087088",
   337 => x"2a813270",
   338 => x"81065151",
   339 => x"5170f138",
   340 => x"73720c83",
   341 => x"3d0d0495",
   342 => x"cc08802e",
   343 => x"bf3895d0",
   344 => x"08822e09",
   345 => x"81069e38",
   346 => x"80c0a980",
   347 => x"8c0b9d80",
   348 => x"0c80c0a9",
   349 => x"80940b9d",
   350 => x"840c0b0b",
   351 => x"0b95a80b",
   352 => x"9cf80cb3",
   353 => x"39838080",
   354 => x"0b9d800c",
   355 => x"82a0800b",
   356 => x"9d840c82",
   357 => x"90800b9c",
   358 => x"f80c9c39",
   359 => x"f8808080",
   360 => x"a40b9d80",
   361 => x"0cf88080",
   362 => x"82800b9d",
   363 => x"840cf880",
   364 => x"8084800b",
   365 => x"9cf80c04",
   366 => x"f33d0d7f",
   367 => x"9d840856",
   368 => x"5c82750c",
   369 => x"8059805a",
   370 => x"805b7a84",
   371 => x"299d8408",
   372 => x"05700871",
   373 => x"08719f2c",
   374 => x"7e852b58",
   375 => x"5555913d",
   376 => x"f8055359",
   377 => x"57a83f7c",
   378 => x"7e7a7207",
   379 => x"7c720771",
   380 => x"71608105",
   381 => x"415f5d5b",
   382 => x"59575581",
   383 => x"7b27cb38",
   384 => x"767c0c77",
   385 => x"841d0c7b",
   386 => x"800c8f3d",
   387 => x"0d048c08",
   388 => x"028c0cf5",
   389 => x"3d0d8c08",
   390 => x"9405089d",
   391 => x"388c088c",
   392 => x"05088c08",
   393 => x"9005088c",
   394 => x"08880508",
   395 => x"58565473",
   396 => x"760c7484",
   397 => x"170c81bf",
   398 => x"39800b8c",
   399 => x"08f0050c",
   400 => x"800b8c08",
   401 => x"f4050c8c",
   402 => x"088c0508",
   403 => x"8c089005",
   404 => x"08565473",
   405 => x"8c08f005",
   406 => x"0c748c08",
   407 => x"f4050c8c",
   408 => x"08f8058c",
   409 => x"08f00556",
   410 => x"56887054",
   411 => x"75537652",
   412 => x"54858d3f",
   413 => x"a00b8c08",
   414 => x"94050831",
   415 => x"8c08ec05",
   416 => x"0c8c08ec",
   417 => x"05088024",
   418 => x"9d38800b",
   419 => x"8c08f405",
   420 => x"0c8c08ec",
   421 => x"0508308c",
   422 => x"08fc0508",
   423 => x"712b8c08",
   424 => x"f0050c54",
   425 => x"b9398c08",
   426 => x"fc05088c",
   427 => x"08ec0508",
   428 => x"2a8c08e8",
   429 => x"050c8c08",
   430 => x"fc05088c",
   431 => x"08940508",
   432 => x"2b8c08f4",
   433 => x"050c8c08",
   434 => x"f805088c",
   435 => x"08940508",
   436 => x"2b708c08",
   437 => x"e8050807",
   438 => x"8c08f005",
   439 => x"0c548c08",
   440 => x"f005088c",
   441 => x"08f40508",
   442 => x"8c088805",
   443 => x"08585654",
   444 => x"73760c74",
   445 => x"84170c8c",
   446 => x"08880508",
   447 => x"800c8d3d",
   448 => x"0d8c0c04",
   449 => x"8c08028c",
   450 => x"0cf93d0d",
   451 => x"800b8c08",
   452 => x"fc050c8c",
   453 => x"08880508",
   454 => x"8025ab38",
   455 => x"8c088805",
   456 => x"08308c08",
   457 => x"88050c80",
   458 => x"0b8c08f4",
   459 => x"050c8c08",
   460 => x"fc050888",
   461 => x"38810b8c",
   462 => x"08f4050c",
   463 => x"8c08f405",
   464 => x"088c08fc",
   465 => x"050c8c08",
   466 => x"8c050880",
   467 => x"25ab388c",
   468 => x"088c0508",
   469 => x"308c088c",
   470 => x"050c800b",
   471 => x"8c08f005",
   472 => x"0c8c08fc",
   473 => x"05088838",
   474 => x"810b8c08",
   475 => x"f0050c8c",
   476 => x"08f00508",
   477 => x"8c08fc05",
   478 => x"0c80538c",
   479 => x"088c0508",
   480 => x"528c0888",
   481 => x"05085181",
   482 => x"a73f8008",
   483 => x"708c08f8",
   484 => x"050c548c",
   485 => x"08fc0508",
   486 => x"802e8c38",
   487 => x"8c08f805",
   488 => x"08308c08",
   489 => x"f8050c8c",
   490 => x"08f80508",
   491 => x"70800c54",
   492 => x"893d0d8c",
   493 => x"0c048c08",
   494 => x"028c0cfb",
   495 => x"3d0d800b",
   496 => x"8c08fc05",
   497 => x"0c8c0888",
   498 => x"05088025",
   499 => x"93388c08",
   500 => x"88050830",
   501 => x"8c088805",
   502 => x"0c810b8c",
   503 => x"08fc050c",
   504 => x"8c088c05",
   505 => x"0880258c",
   506 => x"388c088c",
   507 => x"0508308c",
   508 => x"088c050c",
   509 => x"81538c08",
   510 => x"8c050852",
   511 => x"8c088805",
   512 => x"0851ad3f",
   513 => x"8008708c",
   514 => x"08f8050c",
   515 => x"548c08fc",
   516 => x"0508802e",
   517 => x"8c388c08",
   518 => x"f8050830",
   519 => x"8c08f805",
   520 => x"0c8c08f8",
   521 => x"05087080",
   522 => x"0c54873d",
   523 => x"0d8c0c04",
   524 => x"8c08028c",
   525 => x"0cfd3d0d",
   526 => x"810b8c08",
   527 => x"fc050c80",
   528 => x"0b8c08f8",
   529 => x"050c8c08",
   530 => x"8c05088c",
   531 => x"08880508",
   532 => x"27ac388c",
   533 => x"08fc0508",
   534 => x"802ea338",
   535 => x"800b8c08",
   536 => x"8c050824",
   537 => x"99388c08",
   538 => x"8c050810",
   539 => x"8c088c05",
   540 => x"0c8c08fc",
   541 => x"0508108c",
   542 => x"08fc050c",
   543 => x"c9398c08",
   544 => x"fc050880",
   545 => x"2e80c938",
   546 => x"8c088c05",
   547 => x"088c0888",
   548 => x"050826a1",
   549 => x"388c0888",
   550 => x"05088c08",
   551 => x"8c050831",
   552 => x"8c088805",
   553 => x"0c8c08f8",
   554 => x"05088c08",
   555 => x"fc050807",
   556 => x"8c08f805",
   557 => x"0c8c08fc",
   558 => x"0508812a",
   559 => x"8c08fc05",
   560 => x"0c8c088c",
   561 => x"0508812a",
   562 => x"8c088c05",
   563 => x"0cffaf39",
   564 => x"8c089005",
   565 => x"08802e8f",
   566 => x"388c0888",
   567 => x"0508708c",
   568 => x"08f4050c",
   569 => x"518d398c",
   570 => x"08f80508",
   571 => x"708c08f4",
   572 => x"050c518c",
   573 => x"08f40508",
   574 => x"800c853d",
   575 => x"0d8c0c04",
   576 => x"fc3d0d76",
   577 => x"70797b55",
   578 => x"5555558f",
   579 => x"72278c38",
   580 => x"72750783",
   581 => x"06517080",
   582 => x"2ea738ff",
   583 => x"125271ff",
   584 => x"2e983872",
   585 => x"70810554",
   586 => x"33747081",
   587 => x"055634ff",
   588 => x"125271ff",
   589 => x"2e098106",
   590 => x"ea387480",
   591 => x"0c863d0d",
   592 => x"04745172",
   593 => x"70840554",
   594 => x"08717084",
   595 => x"05530c72",
   596 => x"70840554",
   597 => x"08717084",
   598 => x"05530c72",
   599 => x"70840554",
   600 => x"08717084",
   601 => x"05530c72",
   602 => x"70840554",
   603 => x"08717084",
   604 => x"05530cf0",
   605 => x"1252718f",
   606 => x"26c93883",
   607 => x"72279538",
   608 => x"72708405",
   609 => x"54087170",
   610 => x"8405530c",
   611 => x"fc125271",
   612 => x"8326ed38",
   613 => x"7054ff83",
   614 => x"39fd3d0d",
   615 => x"800b95d0",
   616 => x"08545472",
   617 => x"812e9838",
   618 => x"739d880c",
   619 => x"f7a93ff4",
   620 => x"cf3f95e0",
   621 => x"528151f6",
   622 => x"a43f8008",
   623 => x"519e3f72",
   624 => x"9d880cf7",
   625 => x"923ff4b8",
   626 => x"3f95e052",
   627 => x"8151f68d",
   628 => x"3f800851",
   629 => x"873f00ff",
   630 => x"3900ff39",
   631 => x"f73d0d7b",
   632 => x"95e40882",
   633 => x"c811085a",
   634 => x"545a7780",
   635 => x"2e80d938",
   636 => x"81881884",
   637 => x"1908ff05",
   638 => x"81712b59",
   639 => x"55598074",
   640 => x"2480e938",
   641 => x"807424b5",
   642 => x"3873822b",
   643 => x"78118805",
   644 => x"56568180",
   645 => x"19087706",
   646 => x"5372802e",
   647 => x"b5387816",
   648 => x"70085353",
   649 => x"79517408",
   650 => x"53722dff",
   651 => x"14fc17fc",
   652 => x"1779812c",
   653 => x"5a575754",
   654 => x"738025d6",
   655 => x"38770858",
   656 => x"77ffad38",
   657 => x"95e40853",
   658 => x"bc1308a5",
   659 => x"387951ff",
   660 => x"853f7408",
   661 => x"53722dff",
   662 => x"14fc17fc",
   663 => x"1779812c",
   664 => x"5a575754",
   665 => x"738025ff",
   666 => x"a938d239",
   667 => x"8057ff94",
   668 => x"397251bc",
   669 => x"13085372",
   670 => x"2d7951fe",
   671 => x"d93fff3d",
   672 => x"0d9ce80b",
   673 => x"fc057008",
   674 => x"525270ff",
   675 => x"2e913870",
   676 => x"2dfc1270",
   677 => x"08525270",
   678 => x"ff2e0981",
   679 => x"06f13883",
   680 => x"3d0d0404",
   681 => x"f3b93f04",
   682 => x"00000040",
   683 => x"64756d6d",
   684 => x"792e6578",
   685 => x"65000000",
   686 => x"43000000",
   687 => x"00ffffff",
   688 => x"ff00ffff",
   689 => x"ffff00ff",
   690 => x"ffffff00",
   691 => x"00000000",
   692 => x"00000000",
   693 => x"00000000",
   694 => x"00000e70",
   695 => x"080a400c",
   696 => x"00000aac",
   697 => x"00000ae8",
   698 => x"00000000",
   699 => x"00000d50",
   700 => x"00000dac",
   701 => x"00000e08",
   702 => x"00000000",
   703 => x"00000000",
   704 => x"00000000",
   705 => x"00000000",
   706 => x"00000000",
   707 => x"00000000",
   708 => x"00000000",
   709 => x"00000000",
   710 => x"00000000",
   711 => x"00000ab8",
   712 => x"00000000",
   713 => x"00000000",
   714 => x"00000000",
   715 => x"00000000",
   716 => x"00000000",
   717 => x"00000000",
   718 => x"00000000",
   719 => x"00000000",
   720 => x"00000000",
   721 => x"00000000",
   722 => x"00000000",
   723 => x"00000000",
   724 => x"00000000",
   725 => x"00000000",
   726 => x"00000000",
   727 => x"00000000",
   728 => x"00000000",
   729 => x"00000000",
   730 => x"00000000",
   731 => x"00000000",
   732 => x"00000000",
   733 => x"00000000",
   734 => x"00000000",
   735 => x"00000000",
   736 => x"00000000",
   737 => x"00000000",
   738 => x"00000000",
   739 => x"00000000",
   740 => x"00000001",
   741 => x"330eabcd",
   742 => x"1234e66d",
   743 => x"deec0005",
   744 => x"000b0000",
   745 => x"00000000",
   746 => x"00000000",
   747 => x"00000000",
   748 => x"00000000",
   749 => x"00000000",
   750 => x"00000000",
   751 => x"00000000",
   752 => x"00000000",
   753 => x"00000000",
   754 => x"00000000",
   755 => x"00000000",
   756 => x"00000000",
   757 => x"00000000",
   758 => x"00000000",
   759 => x"00000000",
   760 => x"00000000",
   761 => x"00000000",
   762 => x"00000000",
   763 => x"00000000",
   764 => x"00000000",
   765 => x"00000000",
   766 => x"00000000",
   767 => x"00000000",
   768 => x"00000000",
   769 => x"00000000",
   770 => x"00000000",
   771 => x"00000000",
   772 => x"00000000",
   773 => x"00000000",
   774 => x"00000000",
   775 => x"00000000",
   776 => x"00000000",
   777 => x"00000000",
   778 => x"00000000",
   779 => x"00000000",
   780 => x"00000000",
   781 => x"00000000",
   782 => x"00000000",
   783 => x"00000000",
   784 => x"00000000",
   785 => x"00000000",
   786 => x"00000000",
   787 => x"00000000",
   788 => x"00000000",
   789 => x"00000000",
   790 => x"00000000",
   791 => x"00000000",
   792 => x"00000000",
   793 => x"00000000",
   794 => x"00000000",
   795 => x"00000000",
   796 => x"00000000",
   797 => x"00000000",
   798 => x"00000000",
   799 => x"00000000",
   800 => x"00000000",
   801 => x"00000000",
   802 => x"00000000",
   803 => x"00000000",
   804 => x"00000000",
   805 => x"00000000",
   806 => x"00000000",
   807 => x"00000000",
   808 => x"00000000",
   809 => x"00000000",
   810 => x"00000000",
   811 => x"00000000",
   812 => x"00000000",
   813 => x"00000000",
   814 => x"00000000",
   815 => x"00000000",
   816 => x"00000000",
   817 => x"00000000",
   818 => x"00000000",
   819 => x"00000000",
   820 => x"00000000",
   821 => x"00000000",
   822 => x"00000000",
   823 => x"00000000",
   824 => x"00000000",
   825 => x"00000000",
   826 => x"00000000",
   827 => x"00000000",
   828 => x"00000000",
   829 => x"00000000",
   830 => x"00000000",
   831 => x"00000000",
   832 => x"00000000",
   833 => x"00000000",
   834 => x"00000000",
   835 => x"00000000",
   836 => x"00000000",
   837 => x"00000000",
   838 => x"00000000",
   839 => x"00000000",
   840 => x"00000000",
   841 => x"00000000",
   842 => x"00000000",
   843 => x"00000000",
   844 => x"00000000",
   845 => x"00000000",
   846 => x"00000000",
   847 => x"00000000",
   848 => x"00000000",
   849 => x"00000000",
   850 => x"00000000",
   851 => x"00000000",
   852 => x"00000000",
   853 => x"00000000",
   854 => x"00000000",
   855 => x"00000000",
   856 => x"00000000",
   857 => x"00000000",
   858 => x"00000000",
   859 => x"00000000",
   860 => x"00000000",
   861 => x"00000000",
   862 => x"00000000",
   863 => x"00000000",
   864 => x"00000000",
   865 => x"00000000",
   866 => x"00000000",
   867 => x"00000000",
   868 => x"00000000",
   869 => x"00000000",
   870 => x"00000000",
   871 => x"00000000",
   872 => x"00000000",
   873 => x"00000000",
   874 => x"00000000",
   875 => x"00000000",
   876 => x"00000000",
   877 => x"00000000",
   878 => x"00000000",
   879 => x"00000000",
   880 => x"00000000",
   881 => x"00000000",
   882 => x"00000000",
   883 => x"00000000",
   884 => x"00000000",
   885 => x"00000000",
   886 => x"00000000",
   887 => x"00000000",
   888 => x"00000000",
   889 => x"00000000",
   890 => x"00000000",
   891 => x"00000000",
   892 => x"00000000",
   893 => x"00000000",
   894 => x"00000000",
   895 => x"00000000",
   896 => x"00000000",
   897 => x"00000000",
   898 => x"00000000",
   899 => x"00000000",
   900 => x"00000000",
   901 => x"00000000",
   902 => x"00000000",
   903 => x"00000000",
   904 => x"00000000",
   905 => x"00000000",
   906 => x"00000000",
   907 => x"00000000",
   908 => x"00000000",
   909 => x"00000000",
   910 => x"00000000",
   911 => x"00000000",
   912 => x"00000000",
   913 => x"00000000",
   914 => x"00000000",
   915 => x"00000000",
   916 => x"00000000",
   917 => x"00000000",
   918 => x"00000000",
   919 => x"00000000",
   920 => x"00000000",
   921 => x"ffffffff",
   922 => x"00000000",
   923 => x"ffffffff",
   924 => x"00000000",
   925 => x"00000000",
  others => x"00000000"
);
begin
   busy_o <= re_i; -- we're done on the cycle after we serve the read request

   do_ram:
   process (clk_i)
      variable iaddr : integer;
   begin
      if rising_edge(clk_i) then
         if we_i='1' then
            ram(to_integer(addr_i)) <= write_i;
         end if;
         addr_r <= addr_i;
      end if;
   end process do_ram;
   read_o <= ram(to_integer(addr_r));
end architecture rtl; -- Entity: SinglePortRAM

