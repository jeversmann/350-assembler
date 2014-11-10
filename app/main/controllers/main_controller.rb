class MainController < Volt::ModelController

  def index
    # Add code for when the index view is loaded
    page._raw_assembly = ''
    page._assembler = '16cubed'
  end

  def about
    # Add code for when the about view is loaded
  end

  def assembled
    case page._assembler
    when '16cubed'
      cubed_assemble(page._raw_assembly)
    when 'c16'
      c_assemble(page._raw_assembly)
    else
      ''
    end
  end

  private

  # the main template contains a #template binding that shows another
  # template.  This is the path to that template.  It may change based
  # on the params._controller and params._action values.
  def main_path
    params._controller.or('main') + '/' + params._action.or('index')
  end

  $three_operand_cubed = {
    'ADD' => '1', 'SUB' => '2', 'AND' => '3',
    'OR' => '4', 'XOR' => '5'
  }

  $two_operand_cubed = {
    'MULT' => '1', 'DIV' => '2', 'SLT' => '3', 'SLTU' => '4',
    'SLE' => '5', 'SLEU' => '6', 'SGT' => '7', 'SGTU' => '8',
    'SGE' => '9', 'SGEU' => 'A', 'SE' =>  'B', 'SNE' => 'C',
    'SHL' => 'D', 'SHRA' => 'E', 'SHRL' => 'F'
  }

  $one_operand_cubed = {
    'JR' =>  '0', 'MFHI' => '1', 'MTHI' => '2', 'MFLO' => '3',
    'MTLO' => '4', 'ROR' => '5', 'ROL' => '6', 'JALR' => '7'
  }

  $two_and_imm_cubed = {'SH' => '6', 'LH' => '7'}

  $one_and_imm_cubed = {
    'LH' =>  'A', 'LI' =>  'B', 'SH' =>  'C',
    'BZ' =>  'D', 'BZAL' => 'E'
  }

  $imm_only_cubed = {'J' => 'F'}

  $registers_cubed = {
    'R0' => '0', 'R1' => '1', 'R2' => '2', 'R3' => '3',
    'R4' => '4', 'R5' => '5', 'R6' => '6', 'R7' => '7',
    'R8' => '8', 'R9' => '9', 'R10' => 'A', 'R11' => 'B',
    'R12' => 'C', 'R13' => 'D', 'R14' => 'E', 'R15' => 'F'
  }

  def cubed_assemble(input)
    count = -1
    output = "ADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n"
    input.split("\n").each do |line|
      tokens = line.upcase.split(' ')
      if tokens.size >= 4 && $three_operand_cubed.key?(tokens[0]) && $registers_cubed.key?(tokens[1]) && $registers_cubed.key?(tokens[2]) && $registers_cubed.key?(tokens[3])
        output += (count+=1).to_s + ': ' + $three_operand_cubed[tokens[0]] + $registers_cubed[tokens[1]] + $registers_cubed[tokens[2]] + $registers_cubed[tokens[3]] + ';'
      elsif tokens.size >= 3 && $two_operand_cubed.key?(tokens[0]) && $registers_cubed.key?(tokens[1]) && $registers_cubed.key?(tokens[2])
        output += (count+=1).to_s + ': ' + '0' + $registers_cubed[tokens[1]] + $registers_cubed[tokens[2]] + $two_operand_cubed[tokens[0]] + ';'
      elsif tokens.size >= 4 && $two_and_imm_cubed.key?(tokens[0]) && $registers_cubed.key?(tokens[1]) && $registers_cubed.key?(tokens[2])
        output += (count+=1).to_s + ': ' + $two_and_imm_cubed[tokens[0]] + $registers_cubed[tokens[1]] + $registers_cubed[tokens[2]] + hex(tokens[3], 1) +';'
      elsif tokens.size >= 2 && $one_operand_cubed.key?(tokens[0]) && $registers_cubed.key?(tokens[1])
        output += (count+=1).to_s + ': ' + '0' + $one_operand_cubed[tokens[0]] + $registers_cubed[tokens[1]] + '0;'
      elsif tokens.size >= 3 && $one_and_imm_cubed.key?(tokens[0]) && $registers_cubed.key?(tokens[1])
        output += (count+=1).to_s + ': ' + $one_and_imm_cubed[tokens[0]] + $registers_cubed[tokens[1]] + hex(tokens[2], 2) + ';'
      elsif tokens.size >= 2 && $imm_only_cubed.key?(tokens[0])
        output += (count+=1).to_s + ': ' + $imm_only_cubed[tokens[0]] + hex(tokens[1], 3) + ';'
      end
      output += ' -- ' + line + "\n"
    end
    "WIDTH=16;\nDEPTH=" + count.to_s + ";\n\n" + output + 'END;'
  end

  $c_registers = {
    'R0' => '000', 'R1' => '001', 'R2' => '010', 'R3' => '011',
    'R4' => '100', 'R5' => '101', 'R6' => '110', 'R7' => '111',
  }

  def c_assemble(input)
    count = -1
    output = "ADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n"
    input.split("\n").each do |line|
      tokens = line.upcase.split(' ')
      case tokens[0]
      when 'ADD'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '00001' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '00000' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'SUB'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '00011' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '00010' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'SLT'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '00101' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '00100' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'SLTU'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '00111' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '00110' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'AND'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '01001' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '01000' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'OR'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '01011' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '01010' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'XOR'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          if($c_registers.key?(tokens[3]))
            ins = '01101' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          else
            ins = '01100' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
          end
        end
      when 'SWI'
      when 'EXT'
      when 'MUL'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]) && $c_registers.key?(tokens[3]))
          ins = '10001' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'SHL'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '10000' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '0' + bin(tokens[3], 4)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'DIV'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]) && $c_registers.key?(tokens[3]))
            ins = '10011' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + '00' + $c_registers[tokens[3]]
            output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'SHR'
        if(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '10010' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'LD'
        if(tokens.size > 2 && $c_registers.key?(tokens[1]) && !$c_registers.key?(tokens[2]))
          ins = '10101' + $c_registers[tokens[1]] + bin(tokens[2], 8)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        elsif(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '10100' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'ST'
        if(tokens.size > 2 && $c_registers.key?(tokens[1]) && !$c_registers.key?(tokens[2]))
          ins = '10111' + $c_registers[tokens[1]] + bin(tokens[2], 8)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        elsif(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '10110' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'LEA'
        if(tokens.size > 2 && $c_registers.key?(tokens[1]) && !$c_registers.key?(tokens[2]))
          ins = '11001' + $c_registers[tokens[1]] + bin(tokens[2], 8)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        elsif(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '11000' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'CALL'
        if(tokens.size > 2 && $c_registers.key?(tokens[1]) && !$c_registers.key?(tokens[2]))
          ins = '11011' + $c_registers[tokens[1]] + bin(tokens[2], 8)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        elsif(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '11010' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'BRNZ'
        if(tokens.size > 2 && $c_registers.key?(tokens[1]) && !$c_registers.key?(tokens[2]))
          ins = '11101' + $c_registers[tokens[1]] + bin(tokens[2], 8)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        elsif(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '11100' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      when 'BRZ'
        if(tokens.size > 2 && $c_registers.key?(tokens[1]) && !$c_registers.key?(tokens[2]))
          ins = '11111' + $c_registers[tokens[1]] + bin(tokens[2], 8)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        elsif(tokens.size > 3 && $c_registers.key?(tokens[1]) && $c_registers.key?(tokens[2]))
          ins = '11110' + $c_registers[tokens[1]] + $c_registers[tokens[2]] + bin(tokens[3], 5)
          output += (count+=1).to_s + ': ' + bin_to_hex(ins) + ';'
        end
      end
      output += ' -- ' + line + "\n"
    end
    "WIDTH=16;\nDEPTH=" + count.to_s + ";\n\n" + output + 'END;'
  end

  # Note, this does not warn of overflow right now
  def hex(num, len)
    hs = ('0' * len) + num.to_i.to_s(16)
    hs[hs.size-len..hs.size]
  end

  # Note, this does not warn of overflow right now
  def bin(num, len)
    hs = ('0' * len) + num.to_i.to_s(2)
    hs[hs.size-len..hs.size]
  end

  def bin_to_hex(num)
    hs = ('1' + num).to_i(2).to_s(16)
    hs[1..hs.size - 1]
  end
end
