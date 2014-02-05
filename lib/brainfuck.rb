module Brainfuck
  class Compiler
    TAPE_SIZE = 1024

    def initialize
      @tape = Array.new(TAPE_SIZE, 0)
      @index = 0
      @loop = false
    end

    def run(program)
      program_index = 0
      while (program_index < program.length) do
        char = program[program_index].chr

        case char
        when '>'
          @index = @index >= (TAPE_SIZE - 1) ? TAPE_SIZE - 1 : @index + 1
        when '<'
          @index = @index <= 1 ? 0 : @index - 1
        when '+'
          @tape[@index] += 1
        when '-'
          @tape[@index] -= 1
        when ','
          @tape[@index] = STDIN.getc
        when '.'
          print @tape[@index].chr
        when '['
          i = program_index
          if @tape[@index] == 0
            loop_end = nil

            # Find nearest loop end and skip past it.
            while i < program.length do
              if program[i].chr == ']'
                loop_end = i
                break
              else
                i += 1
              end
            end

            raise "Nooo" unless loop_end
            program_index = loop_end + 1
          end
        when ']'
          i = program_index
          loop_start = nil

          while i >= 0 do
            if program[i].chr == '['
              loop_start = i
              break
            else
              i -= 1
            end
          end
          raise "Nuu" unless loop_start
          program_index = loop_start - 1
        when ' ', "\n"
        else
          raise "Invalid character: #{char.inspect}"
        end

        program_index += 1
      end
    end
  end
end

def main
  str =<<EOS
+++++ +++++
[
    > +++++ ++
    > +++++ +++++
    > +++
    > +
    <<<< -
]
> ++ .
> + .
+++++ ++ .
.
+++ .
> ++ .
<< +++++ +++++ +++++ .
> .
+++ .
----- - .
----- --- .
> + .
> .
EOS

  Brainfuck::Compiler.new.run(str)
end


if $0 == __FILE__
  main
end
