library ieee;
use ieee.std_logic_1164.all;

entity CPU is
    port(
        clk			: in  std_logic; 
		n_rst 		: in  std_logic;
        I 			: in  std_logic_vector(12 downto 0);
        INPUT 		: in  std_logic_vector(7 downto 0);
        A 			: out std_logic_vector(5 downto 0);
        OUTPUT 		: out std_logic_vector(7 downto 0);
        OutEna 		: out std_logic;
        pc_debug 	: out std_logic_vector(5 downto 0);
		int_source0	: in  std_logic
		
    );
end CPU;

architecture Structural of CPU is
	
	component program_counter is
		port(
			clk 		: in  std_logic;
			n_rst		: in  std_logic;
			pc			: in  std_logic_vector(5 downto 0);
			pc_debug	: out std_logic_vector(5 downto 0);
			pc_p_one	: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component destination is
		port(
			regEna : in  std_logic;
			I_dest : in  std_logic;
			ena0   : out std_logic;
			ena1   : out std_logic
		);
	end component;
	
	component MUX3x6 is
		port(
			input0 : in  std_logic_vector(5 downto 0);
			input1 : in  std_logic_vector(5 downto 0);
			input2 : in  std_logic_vector(5 downto 0);
			sel    : in  std_logic_vector(1 downto 0);
			output : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component MUX2x8 is
		port(
			input0 	: in  std_logic_vector(7 downto 0);
			input1	: in  std_logic_vector(7 downto 0);
			sel    	: in  std_logic;
			output  : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component ALU is
    port(
        A 	  	: in  std_logic_vector(7 downto 0);
        B 	  	: in  std_logic_vector(7 downto 0);
        ALUop 	: in  std_logic_vector(2 downto 0);
        Z 	  	: out std_logic;			 			
        output 	: out std_logic_vector(7 downto 0)
    );
	end component;
	
	--detta ska tas bort sen
	component work_reg is
	port(
		clk   : in  std_logic;
		ena   : in  std_logic;
		n_rst : in  std_logic;
		D 	  : in  std_logic_vector(7 downto 0);
		Q 	  : out std_logic_vector(7 downto 0)
	);
	end component;
	
	--deklaration av work_reg_block
	component work_reg_block is
	port(
	   save_wreg : in STD_LOGIC;
	   D : in STD_LOGIC_VECTOR(7 downto 0);
       restore_wreg : in STD_LOGIC;
       ena : in STD_LOGIC;
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       Q : out STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component decoder is
    port(
        OPCODE 	: in  std_logic_vector(3 downto 0);
        Z 		: in  std_logic;
        AddrSrc : out std_logic_vector(1 downto 0);
        ALUOp 	: out std_logic_vector(2 downto 0);
        ALUSrc 	: out std_logic;
        OutEna 	: out std_logic;
        RegEna 	: out std_logic;
        StackOp : out std_logic_vector(1 downto 0);
        SRET    : out std_logic_vector(3 downto 0)
    );
	end component;
	
	component stack is
	port(
        clk		: in  std_logic;
		n_rst 	: in  std_logic;
        StackOp : in  std_logic_vector(1 downto 0);
        D 		: in  std_logic_vector(5 downto 0);
        ToS 	: out std_logic_vector(5 downto 0)
	);
	end component;
	
	component MUX2x6 is
    port(
        input0     : in  std_logic_vector(5 downto 0);
        input1    : in  std_logic_vector(5 downto 0);
        sel        : in  std_logic;
        output  : out std_logic_vector(5 downto 0)
    );
    end component;
        
    component avbrottshanterare is
    port(
       ret_addr : in std_logic_vector(5 downto 0);
       int_done : in std_logic;
       clk : in std_logic;
       rst : in std_logic;
       int0 : in std_logic;
       int_addr : out std_logic_vector(5 downto 0);
       int_mux : out std_logic;
       save_wreg : out std_logic;
       restore_wreg : out std_logic 
    );
    end component;
	
	signal s_dest     	: std_logic;
	signal s_data     	: std_logic_vector(7 downto 0);
	signal s_d_addr  	: std_logic_vector(5 downto 0);
	signal s_opcode 	: std_logic_vector(3 downto 0);
	signal s_Z 			: std_logic;
	signal s_addrSrc  	: std_logic_vector(1 downto 0);
	signal s_ALUOp 		: std_logic_vector(2 downto 0);
	signal s_ALUSrc 	: std_logic;
    signal s_OutEna 	: std_logic;
    signal s_RegEna 	: std_logic;
    signal s_StackOp  	: std_logic_vector(1 downto 0);
    signal s_SRET       : std_logic_vector(3 downto 0);
	
	signal s_next_instr : std_logic_vector(5 downto 0);
	signal s_pc_p_one   : std_logic_vector(5 downto 0);
	signal s_TOS	 	: std_logic_vector(5 downto 0);
	signal s_input 		: std_logic_vector(7 downto 0);
	signal s_back 		: std_logic_vector(7 downto 0);
	signal s_ena0 		: std_logic;
	signal s_ena1	 	: std_logic;
	signal s_output 	: std_logic_vector(7 downto 0);
	signal s_B 			: std_logic_vector(7 downto 0);
	signal s_R0Q		: std_logic_vector(7 downto 0);
	signal s_R1Q		: std_logic_vector(7 downto 0);
	signal s_pc_debug	: std_logic_vector(5 downto 0);
	signal restore_wreg0 : std_logic;
	signal restore_wreg1 : std_logic;
    signal save_wreg0 : std_logic;
    signal save_wreg1 : std_logic;
    ----
    signal s_int_addr : std_logic_vector(5 downto 0);
    signal s_int_mux : std_logic;
    signal s_instr : std_logic_vector(5 downto 0);
    signal ret_addr : std_logic_vector (5 downto 0);
    signal int_done : std_logic;
    signal s_int_done : std_logic;
    signal restore_wreg : std_logic;


begin
	
	-- Inputs
	s_opcode  <= I(12 downto 9);
	s_dest    <= I(8);
    s_data    <= I(7 downto 0);
	s_d_addr  <= I(5 downto 0);
	s_input	  <= INPUT;
	
	-- Outputs
	A 		 <= s_next_instr;
	OUTPUT 	 <= s_output;
	OutEna 	 <= s_OutEna;
	pc_debug <= s_pc_debug;

	pc: program_counter
	port map(
		clk 		=> clk,
	    n_rst		=> n_rst,
	    pc			=> s_next_instr,
		pc_debug	=> s_pc_debug,
	    pc_p_one	=> s_pc_p_one
	);
	
	dest: destination
	port map(
		regEna => s_RegEna,
		I_dest => s_dest,
		ena0   => s_ena0,
		ena1   => s_ena1
	);
	
	MUX1: MUX3x6
	port map(
		input0 => s_pc_p_one,
		input1 => s_TOS,
		input2 => s_d_addr,
		sel    => s_addrSrc,
		output => s_instr           --s_next_instr
	);
	
	MUX2: MUX2x8
	port map(
		input0 	=> s_back,
		input1	=> s_input,
		sel    	=> s_ALUSrc,
		output  => s_B
	);
	
	MUX3: MUX2x8
	port map(
		input0 	=> s_R0Q,
		input1	=> s_R1Q,
		sel    	=> s_dest,
		output  => s_back
	);
	
	MUX4: MUX2x6
    port map(
        input0     => s_instr,
        input1    => s_int_addr,
        sel        => s_int_mux,
        output  => s_next_instr
    );
	
	theALU: ALU 
    port map(
        A 	  	=> s_data,
        B 	  	=> s_B,
        ALUop 	=> s_ALUOp,
        Z 	  	=> s_Z,
        output 	=> s_output
    );
    
--remove both these shit later
	--R0: work_reg 
	--port map(
		--clk   => clk,
		--ena   => s_ena0,
		--n_rst => n_rst,
		--D 	  => s_output,
		--Q 	  => s_R0Q
	--);
	
	--R1: work_reg 
--	port map(
	--	clk   => clk,
	--	ena   => s_ena1,
	--	n_rst => n_rst,
	--	D 	  => s_output,
	--	Q 	  => s_R1Q
	--);
	
    R0: work_reg_block
    port map(
        save_wreg => save_wreg0,
        D => s_output,
        restore_wreg => restore_wreg0,
        ena => s_ena0,
        clk => clk,
        rst => n_rst,
        Q => s_R0Q
    );
    
    R1: work_reg_block
    port map(
        save_wreg => save_wreg1,
        D => s_output,
        restore_wreg => restore_wreg1,
        ena => s_ena1,
        clk => clk,
        rst => n_rst,
        Q => s_R1Q 
    );      
           
	DEC: decoder 
    port map(
        OPCODE 	=> s_opcode,
        Z 		=> s_Z,
        AddrSrc => s_addrSrc,
        ALUOp 	=> s_ALUOp,
        ALUSrc 	=> s_ALUSrc,
        OutEna 	=> s_OutEna,
        RegEna 	=> s_RegEna,
        StackOp => s_StackOp,
        SRET    => s_SRET
    );
    
    avbrott: avbrottshanterare
    port map(
       int_addr => s_int_addr,
       int_done => s_int_done,
       clk      => clk,
       rst      => n_rst,
       ret_addr => s_pc_debug,
       int0     => int_source0,
       int_mux  => s_int_mux,
       save_wreg => save_wreg0,
       restore_wreg => restore_wreg
    );
	
	theStack: stack 
	port map(
		clk		=> clk,
		n_rst 	=> n_rst,
		StackOp => s_StackOp,
		D 		=> s_pc_p_one,
		ToS 	=> s_TOS
	);

end Structural;
