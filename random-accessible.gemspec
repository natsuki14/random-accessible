Gem::Specification.new do |s|
  s.name = 'random-accessible'
  s.version = '0.1.3'
  s.summary = <<EOS
RandomAccessible mixin provides all methods of Array.
EOS
  s.description = <<EOS
RandomAccessible mixin provides all methods of Array (regard as high-functioning edition of Enumerable).
As a class includes Enumerable must provide "each" method, a class includes RandomAccessible must have some methods. (please see the document for detail).

EOS
  s.authors = ["Natsuki Kawai"]
  s.email = ['natsuki.kawai@gmail.com']
  s.files = Dir['lib/*.rb'] + Dir['test/*.rb'] + ['BSDL']
  s.extra_rdoc_files = ['README.en']
  s.licenses = ["Ruby's", '2-clause BSDL']
  s.test_files = Dir['test/test-suite.rb']
  s.homepage = 'https://github.com/natsuki14/random-accessible'
end
