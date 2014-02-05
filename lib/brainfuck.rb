
module Brainfuck
  class BrainfuckError < StandardError; end
  class InvalidSyntaxError < BrainfuckError; end
  class EndOfTapeError < BrainfuckError; end

  class Tape
    LENGTH = 30_000

    def initialize
      @tape = Array.new(LENGTH, 0)
      @index = 0
    end

    # Brainfuck spec.
    def current_value; @tape[@index]; end
    def null?; @tape[@index] == 0; end
    def >
      raise EndOfTapeError if @index == (@tape.length - 1)
      @index += 1
    end
    def <; @index -= 1 unless @index == 0; end
    def +; @tape[@index] += 1; end
    def -; @tape[@index] -= 1; end
    def getc; @tape[@index] = STDIN.getc.to_i; end
    def putc; print @tape[@index].chr; end
  end

  class Interpreter
    def initialize
      @tape = Tape.new
    end

    def run(program)
      index = 0
      comment = false

      while (index < program.length) do
        char = program[index].chr
        index += 1

        if comment
          comment = false if char == "\n"
          next
        end

        case char
        when '#' then comment = true
        when '>' then @tape.>
        when '<' then @tape.<
        when '+' then @tape.+
        when '-' then @tape.-
        when ',' then @tape.getc
        when '.' then @tape.putc
        when /\s/
        when '['
          i = index

          # Skip the loop conditionally.
          next unless @tape.null?

          # Find associated loop end end and skip past it.
          loop_end_index = nil
          num_loop_starts_seen = 0
          num_loop_ends_seen = 0

          while i < program.length do
            if program[i].chr == ']'
              if num_loop_starts_seen == num_loop_ends_seen
                loop_end_index = i
                break
              else
                num_loop_ends_seen += 1
              end
            elsif program[i].chr == '['
              num_loop_starts_seen += 1
            end

            i += 1
          end
          raise InvalidSyntaxError.new("Unmatched [") unless loop_end_index

          index = loop_end_index + 1
        when ']'
          i = index - 2 # Start from before the ]
          loop_start_index = nil
          num_loop_ends_seen = 0
          num_loop_starts_seen = 0

          while i >= 0 do
            if program[i].chr == '['
              if num_loop_ends_seen == num_loop_starts_seen
                loop_start_index = i
                break
              else
                num_loop_starts_seen += 1
              end
            elsif program[i].chr == ']'
              num_loop_ends_seen += 1
            end
            i -= 1
          end
          raise InvalidSyntaxError.new("Unmatched ]") unless loop_start_index
          index = loop_start_index
        else
          raise InvalidSyntaxError.new("Unknown character: #{char.inspect}")
        end
      end
    end
  end
end
