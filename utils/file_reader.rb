class FileReader
  def self.read_lines(file_path)
    File.readlines(file_path, chomp: true)
  end
end