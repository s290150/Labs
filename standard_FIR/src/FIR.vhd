library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;

ENTITY FIR IS
		PORT(	D_IN : IN SIGNED(Nb-1 DOWNTO 0);
				H0 : IN SIGNED(Nb-1 DOWNTO 0);
				H1 : IN SIGNED(Nb-1 DOWNTO 0);
				H2 : IN SIGNED(Nb-1 DOWNTO 0);
				H3 : IN SIGNED(Nb-1 DOWNTO 0);
				H4 : IN SIGNED(Nb-1 DOWNTO 0);
				H5 : IN SIGNED(Nb-1 DOWNTO 0);
				H6 : IN SIGNED(Nb-1 DOWNTO 0);
				H7 : IN SIGNED(Nb-1 DOWNTO 0);
				H8 : IN SIGNED(Nb-1 DOWNTO 0);
				H9 : IN SIGNED(Nb-1 DOWNTO 0);
				H10 : IN SIGNED(Nb-1 DOWNTO 0);
				V_IN : IN STD_LOGIC;
				RST_N : IN STD_LOGIC;
				CLK : IN STD_LOGIC;
				V_OUT : OUT STD_LOGIC;
				D_OUT : OUT SIGNED(Nb-1 DOWNTO 0));
END ENTITY;

ARCHITECTURE BEHAV OF FIR IS
--Components declaration
	COMPONENT REG IS
		PORT( DIN : IN SIGNED(Nb-1 DOWNTO 0);
				CLK : IN STD_LOGIC;
				RST_N : IN STD_LOGIC;
				EN : IN STD_LOGIC;
				DOUT : OUT SIGNED(Nb-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT FF IS
		PORT(
		D : IN STD_LOGIC;
		CLK : IN STD_LOGIC;
		RST_N : IN STD_LOGIC;
		EN : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT FF_2 IS
		PORT(
		D : IN STD_LOGIC;
		CLK : IN STD_LOGIC;
		RST_N : IN STD_LOGIC;
		EN : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
	END COMPONENT;
	
-- Signals declaration
	SIGNAL b : data_array; -- COEFFICIENTS
	SIGNAL D_STAGE : data_array; -- SIGNALS BETWEEN REGISTERS
	SIGNAL POTATO_FF: data_ff; -- SIGNALS BETWEEN FF
	SIGNAL OUT_MULT : mult_out_array; -- OUTPUT OF MULTIPLIERS
	SIGNAL OUT_MULT_TRUNC : mult_in; -- OUTPUT OF TRUNCATIONS
	SIGNAL OUT_ADD : add_in; -- OUTPUT OF ADDERS

	BEGIN
	
	-- HERE WE ARE ASSIGNING COEFFICIENTS TO AN ARRAY IN ORDER TO BETTER PARAMETERIZE THE ENTITY

	b(0) <= H0;
	b(1) <= H1;
	b(2) <= H2;
	b(3) <= H3;
	b(4) <= H4;
	b(5) <= H5;
	b(6) <= H6;
	b(7) <= H7;
	b(8) <= H8;
	b(9) <= H9;
	b(10) <= H10;

-- REGISTERS STAGES
		
		INPUT_REG1: REG PORT MAP (DIN => D_IN, CLK => CLK, EN => V_IN, RST_N => RST_N, DOUT => D_STAGE(0));
		
		FIR_STAGES: FOR I IN 1 TO Nt-1 GENERATE
						STAGE_I : REG PORT MAP (DIN => D_STAGE(I-1), CLK => CLK, EN => V_IN, RST_N => RST_N, DOUT => D_STAGE(I));
						END GENERATE;
		OUTPUT_REG: REG PORT MAP (DIN => OUT_ADD(NT-2)(Nb-1 DOWNTO 0), CLK => CLK, EN => POTATO_FF(0), RST_N => RST_N, DOUT => D_OUT);
		
-- CHAIN OF FFs FOR VIN -> VOUT

	FF_IN: FF PORT MAP (V_IN, CLK, RST_N, V_IN, POTATO_FF(0));
	FF_OUT: FF_2 PORT MAP (POTATO_FF(0), CLK, RST_N, V_IN, V_OUT);
		
		
		
--	MULTIPLICATIONS AND TRUNCATIONS
		FIR_MULT: FOR I IN 0 TO Nt-1 GENERATE
						OUT_MULT(I) <= D_STAGE(I) * b(I);
						OUT_MULT_TRUNC(I) <= OUT_MULT(I)(2*Nb-1 DOWNTO 2*Nb-Nb-1);
					 END GENERATE;
		
-- SUMS AND TRUNCATIONS
		OUT_ADD(0) <= OUT_MULT_TRUNC(0) + OUT_MULT_TRUNC(1); --SCALO A DESTRA PER RIMPIAZZARE L'MSB A SINISTRA
		
		FIR_SUM: FOR I IN 1 TO NT-2 GENERATE
					OUT_ADD(I) <= OUT_MULT_TRUNC(I+1) + OUT_ADD(I-1);
					END GENERATE;
END ARCHITECTURE;