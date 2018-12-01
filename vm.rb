# read binary file
data = File.open('challenge.bin', 'rb').readlines

# pack to bitsteeam
binary = data.flat_map { |s| s.unpack('b*') }.join

# 16 bit values in little-endian format
program = binary.chars.each_slice(16).map { |i| i.reverse.join }


stack = []

registers = {
  0 => 0,
  1 => 0,
  2 => 0,
  3 => 0,
  4 => 0,
  5 => 0,
  6 => 0,
  7 => 0
}

args = []

opcodes = {
  0 => :halt,
  1 => :set,
  19 => :out,
  21 => :noop
}

def halt(*)
  exit
end

# set: 1 a b
# set register <a> to the value of <b>
def set(args)
  registers[args[0]] = args[1]
end

def out(args)
  print(args[0].chr)
end

def noop(*)
end

@pc = 0
loop do
  seq = program[@pc].to_i(2)
  case seq

  # literals
  when 0..32767
    if (0..21).include?(seq)
      if @op
        send(@op, args)
        # execute
      end
      args = []
      @op = opcodes[seq]
    else
      args << seq
    end
  # registers
  when 32768..32775
    reg_index = (seq - 32768).to_s
    args << reg_index
  else
    # invalid values
  end
  @pc += 1
end
