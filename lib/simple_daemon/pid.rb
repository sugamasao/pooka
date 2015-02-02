# coding: utf-8
require 'pathname'

module SimpleDaemon
  # PID File Manager.
  class PID
    attr_reader :path

    # @param [String] path pid file
    # @param [Fixnum] pid process id
    def initialize(path, pid)
      @path = Pathname(path)
      @pid  = pid
    end

    # create pid file
    # @return [Boolean] create true
    def create
      return false unless create_pid_file?(@path)

      File.write(@path, @pid)
      true
    end

    # delete pid file
    def delete
      @path.delete if @path.file?
    end

    # PIDファイルを指定のpathで作成しなおす
    # @param [String] path pid file path
    # @return [Boolean] create true
    def rename(path)
      path = Pathname(path)

      # nothing to do
      return true if @path == path

      return false unless create_pid_file?(path)
      File.write(path, @pid)

      delete
      @path = path

      true
    end

    private

    # can create pid file?
    # @param [Pathname] path pid file path
    # @return [Boolean] true is can create
    def create_pid_file?(path)
      # already path created.
      return false if path.file?

      # can not created path is directory.
      return false if path.directory?

      # can not create parent path is not directory.
      return false unless path.parent.directory?

      true
    end
  end
end
