Gem::Specification.new do |s|
  s.name = 'random-accessible'
  s.version = '0.1.2'
  s.summary = <<EOS
RandomAccessible mixin provides all methods of Array.
EOS
  s.description = <<EOS
RandomAccessible mixin provides all methods of Array to your classes (regard as high-functioning edition of Enumerable).
As Enumerable mixin requests "each" method, RandomAccessible requests methods below (or alternative, please see README.en for detail).

- size (same as Array#size)

- read_access (similar to Array#[])

- replace_access (similar to Array#[]=)

- shrink (similar to Array#pop)
EOS
  s.authors = ["Natsuki Kawai"]
  s.email = ['natsuki.kawai@gmail.com']
  s.files = Dir['lib/*']
  s.extra_rdoc_files = ['README.en']
  s.licenses = ["Ruby's", '2-clause BSDL']
  s.test_files = ['test/test-suite.rb']
  s.homepage = 'https://github.com/natsuki14/random-accessible'
end
