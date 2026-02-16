## Verible Format Args
```bash
--indentation_spaces=2 --column_limit=100 --line_break_penalty=2 --wrap_spaces=4 --assignment_statement_alignment=align --case_items_alignment=align --class_member_variable_alignment=align --distribution_items_alignment=align --enum_assignment_statement_alignment=align --formal_parameters_alignment=align --module_net_variable_alignment=align --named_parameter_alignment=align --named_port_alignment=align --port_declarations_alignment=align --struct_union_members_alignment=align --failsafe_success=false --verify_convergence=true --max_search_states=1000000 --inplace
```

## Simulation with IVerilog + GTKWave

### Build and run

```bash
cd <project_dir>/src
iverilog -o tb_<module>.vvp tb_<module>.v
vvp tb_<module>.vvp
```

### View waveforms

```bash
gtkwave tb_<module>.vcd
```

### Typical testbench structure

1. **Clock generation**:
   ```verilog
   localparam real CLK_FREQ = <frequency>;
   localparam real CLK_PERIOD = 1e9 / CLK_FREQ;
   initial clk = 0;
   always #(CLK_PERIOD / 2) clk = ~clk;
   ```

2. **Asynchronous reset**:
   ```verilog
   initial begin
       rst_n = 0;
       #(CLK_PERIOD * 2);
       rst_n = 1;
   end
   ```

3. **Signal dump**:
   ```verilog
   initial begin
       $dumpfile("tb_<module>.vcd");
       $dumpvars(0, tb_<module>);
       // ... stimulus ...
       $finish;
   end
   ```

### Best practices

- Use `localparam real` for timing values (allows floating-point in simulation)
- Always wait sufficient time for operations to complete
- Use `$finish` to terminate simulation gracefully
- Check `timescale` at the top of the testbench (e.g., `` `timescale 1ns / 1ps``)

### Debugging

- Expand signal hierarchy in GTKWave to see internal states
- Use `$display()` or `$monitor()` in Verilog for console messages
- Look for unexpected transitions or "stuck" signals