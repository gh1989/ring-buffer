struct RingBuffer<const N: usize> {
  buffer: [i32; N],
  head: usize,
  tail: usize,
}

impl<const N: usize> RingBuffer<N> {
  fn new() -> Self {
    Self {
      buffer: [0; N],
      head: 0,
      tail: 0,
    }
  }

  fn isEmpty(&self) -> bool {
        return self.head == self.tail;
  }

  fn isFull(&self) -> bool {
      return (self.head+1)%N == self.tail
  }
}

fn main()
{
  let mut buf = RingBuffer::<128>::new(); 
  if buf.isEmpty()
  {
    println!("RingBuffer is empty");
  }
}
