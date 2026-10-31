<CodeBlock language="tcl" editable>
transcript on


if {[file exists work]} {
vdel -lib work -all
}

vlib work
vmap work work

vlog -sv rtl/digital_integrator.v
vlog -sv tb/tb_digital_integrator.v

vsim -voptargs=+acc work.tb_digital_integrator

add wave -divider "Testbench Signals"
add wave sim:/tb_digital_integrator/clk
add wave sim:/tb_digital_integrator/rst
add wave sim:/tb_digital_integrator/x_in
add wave sim:/tb_digital_integrator/y_out

add wave -divider "DUT Signals"
add wave sim:/tb_digital_integrator/dut/*

radix -decimal

run -all
wave zoom full
</CodeBlock>