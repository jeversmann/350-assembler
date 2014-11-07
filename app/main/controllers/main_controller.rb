class MainController < Volt::ModelController

  def index
    # Add code for when the index view is loaded
    page._raw_assembly = ""
  end

  def about
    # Add code for when the about view is loaded
  end

  def assembled
    cubed_assemble(page._raw_assembly)
  end

  private

  # the main template contains a #template binding that shows another
  # template.  This is the path to that template.  It may change based
  # on the params._controller and params._action values.
  def main_path
    params._controller.or('main') + '/' + params._action.or('index')
  end

  $three_operand_ins = {
    'ADD' => '1', 'SUB' => '2', 'AND' => '3',
    'OR' => '4', 'XOR' => '5'
  }

  $two_operand_ins = {
    'MULT' => '1', 'DIV' => '2', 'SLT' => '3', 'SLTU' => '4',
    'SLE' => '5', 'SLEU' => '6', 'SGT' => '7', 'SGTU' => '8',
    'SGE' => '9', 'SGEU' => 'A', 'SE' =>  'B', 'SNE' => 'C',
    'SHL' => 'D', 'SHRA' => 'E', 'SHRL' => 'F'
  }

  $one_operand_ins = {
    'JR' =>  '0', 'MFHI' => '1', 'MTHI' => '2', 'MFLO' => '3',
    'MTLO' => '4', 'ROR' => '5', 'ROL' => '6', 'JALR' => '7'
  }

  $two_and_imm_ins = {'SH' => '6', 'LH' => '7'}

  $one_and_imm_ins = {
    'LH' =>  'A', 'LI' =>  'B', 'SH' =>  'C',
    'BZ' =>  'D', 'BZAL' => 'E'
  }

  $registers = {
    'R0' => '0', 'R1' => '1', 'R2' => '2', 'R3' => '3',
    'R4' => '4', 'R5' => '5', 'R6' => '6', 'R7' => '7',
    'R8' => '8', 'R9' => '9', 'R10' => 'A', 'R11' => 'B',
    'R12' => 'C', 'R13' => 'D', 'R14' => 'E', 'R15' => 'F'
  }

  def cubed_assemble(input)
    count = 0
    output = "ADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n"
    input.split("\n").each do |line|
      tokens = line.upcase.split(' ')
      if tokens.size == 4 && $three_operand_ins.key?(tokens[0]) && $registers.key?(tokens[1]) && $registers.key?(tokens[2]) && $registers.key?(tokens[3])
        output += (count+=1).to_s + ': ' + $three_operand_ins[tokens[0]] + $registers[tokens[1]] + $registers[tokens[2]] + $registers[tokens[3]] + ';'
      elsif tokens.size == 3 && $two_operand_ins.key?(tokens[0]) && $registers.key?(tokens[1]) && $registers.key?(tokens[2])
        output += (count+=1).to_s + ': ' + '0000' + $registers[tokens[1]] + $registers[tokens[2]] + $two_operand_ins[tokens[0]] + ';'
      elsif tokens.size == 4 && $two_and_imm_ins.key?(tokens[0]) && $registers.key?(tokens[1]) && $registers.key?(tokens[2])
        output += (count+=1).to_s + ': ' + $two_and_imm_ins[tokens[0]] + $registers[tokens[1]] + $registers[tokens[2]] + 'bits;'
      elsif tokens.size == 2 && $one_operand_ins.key?(tokens[0]) && $registers.key?(tokens[1])
        output += (count+=1).to_s + ': ' + '0000' + $one_operand_ins[tokens[0]] + $registers[tokens[1]] + '0000;'
      elsif tokens.size == 2 && $one_and_imm_ins.key?(tokens[0])
        output += (count+=1).to_s + ': ' + $one_and_imm_ins[tokens[0]] + 'bits;'
      end
      output += ' -- ' + line + "\n"
    end
    "WIDTH=16;\nDEPTH=" + count.to_s + ";\n\n" + output + 'END;'
  end
end
