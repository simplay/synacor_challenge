# read binary file
data = File.open('challenge.bin', 'rb').readlines

# pack to bitsteeam
binary = data.flat_map { |s| s.unpack('b*') }.join

# 16 bit values in little-endian format
program = binary.chars.each_slice(16).map { |i| i.reverse.join }


stack = []

@registers = {
  '0' => 0,
  '1' => 0,
  '2' => 0,
  '3' => 0,
  '4' => 0,
  '5' => 0,
  '6' => 0,
  '7' => 0
}

@args = []

opcodes = {
  0 => { cmd: :halt, args: 0 },
  1 => { cmd: :set, args: 2 },
  6 => { cmd: :jmp, args: 1 },
  7 => { cmd: :jt, args: 2 },
  8 => { cmd: :jf, args: 2 },
  10 => { cmd: :mult, args: 3 },
  14 => { cmd: :not, args: 2 },
  19 => { cmd: :out, args: 1 },
  21 => { cmd: :noop, args: 0 }
}

def fetch_value(value)
  value.is_a?(String) ? @registers[value] : value
end

def halt(*)
  exit
end

# set: 1 a b
# set register <a> to the value of <b>
def set(args)
  b = fetch_value(args[0])
  a = fetch_value(args[1])

  @registers[a.to_s] = b
end

# jmp: 6 a
# jump to <a>
def jmp(args)
  address = fetch_value(args[0])
  @pc = address - 1 if address
  @jump = true
end

# jt: 7 a b
# if <a> is nonzero, jump to <b>
def jt(args)
  a = fetch_value(args[0])
  b = fetch_value(args[1])

  @pc = (b - 1) if a != 0
  @jump = true
end


# jf: 8 a b
# if <a> is zero, jump to <b>
def jf(args)
  a = fetch_value(args[0])
  b = fetch_value(args[1])

  @pc = (b - 1) if a == 0
  @jump = true
end

# mult: 10 a b c
# store into <a> the product of <b> and <c> (modulo 32768)
def mult(args)
  a = fetch_value(args[0])
  b = fetch_value(args[1])
  c = fetch_value(args[2])

  @registers[a] = (b * c) % 32768
end

# not: 14 a b
#   stores 15-bit bitwise inverse of <b> in <a>
def not(args)
  require 'pry'; binding.pry
  puts
end

def out(args)
  if args.empty?
    puts
    return
  end
  print(fetch_value(args[0]).chr)
end

def noop(*)
end

def execute_op
  @hist << "#{@op[:cmd]} #{@args.join(' ')}"
  send(@op[:cmd], @args)
  @args = []
  @op = nil
end

@hist = []
@pc = 0
@jump = false
iteration = -1

loop do
  iteration += 1
  begin
    seq = program[@pc].to_i(2)
    case seq

      # literals
    when 0..32767
      if @op
        if @op[:args] == @args.count
          execute_op
          @op = opcodes[seq] unless @jump
        else
          @args << seq
        end
      else
        @op = opcodes[seq]
      end

      # registers
    when 32768..32775
      reg_index = (seq - 32768).to_s
      @args << reg_index
    else
      # invalid values
    end
    @pc += 1
    @jump = false

    # @jumped = false
  rescue Exception => e
    require 'pry'; binding.pry
    puts
  end
end
