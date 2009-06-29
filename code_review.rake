require 'stringio'
require 'pdf/writer'

task :code_review do
  GitParser.create_review
end

class GitParser
  attr_accessor :changed_output, :untracked_output
  
  def initialize(text)
    @text = text
  end
    
  def create_review
    pdf = PDF::Writer.new
    files.each { |f| pdf.text "\n\n # #{f.path} \n\n #{f.read}" }
    File.open('code_review.pdf', "w") { |file| file.write(pdf.render) }
  end
  
  def self.create_review
    new(%x[echo ; git status])
  end
  
  def files
    @files ||= read.map do |line|
      action, filename = line.to_s.scan(/\S+/).reject(&:blank?) # sometimes there is no action
      (@deleted_files ||= []) << filename if action.strip.eql?("deleted:")
      File.new("#{RAILS_ROOT}/#{filename || action}") rescue nil
    end.compact
  end
    
  def read
    @text.scan(/#\t(.+?)\n/)
  end
    
end
