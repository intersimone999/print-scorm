Gem::Specification.new do |s|
  s.name        = 'print-scorm'
  s.version     = '1.0.0'
  s.date        = '2020-03-03'
  s.summary     = "Exports SCORM packages to PDF"
  s.description = "Exports SCORM packages to PDF"
  s.authors     = ["Simone Scalabrino"]
  s.homepage    = "https://github.com/intersimone999/print-scorm"
  s.email       = 's.scalabrino9@gmail.com'
  s.license     = 'GPL-3.0'
  
  s.files       = ["lib/print-scorm.rb", "bin/print-scorm"]
  s.executables = ["print-scorm"]
  
  s.add_runtime_dependency "watir", "~> 6.16.5", ">= 6.16.0"
  s.add_runtime_dependency "watir-scroll", "~> 0.4.0", ">= 0.4.0"
end
