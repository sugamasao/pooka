# coding: utf-8
require 'pathname'

module SimpleDaemon
  # PID File Manager.
  class PIDManager
    attr_reader :path

    # @param [String] path PIDファイルを作成するパス
    # @param [Fixnum] pid ファイル内に置くpidの値
    def initialize(path, pid)
      @path = Pathname(path)
      @pid  = pid
    end

    # PIDファイルを作成する
    # @return [Boolean] 作成できたら true
    def create
      return false unless create_pid_file?(@path)

      File.write(@path.to_s, @pid)
      true
    end

    # PIDファイルの削除を行う
    def delete
      @path.delete if @path.file?
    end

    # PIDファイルを指定のpathで作成しなおす
    # @return [Boolean] 作成できたらtrue
    def rename(path)
      path = Pathname(path)
      return false unless create_pid_file?(path)

      File.write(path.to_s, @pid)

      return false unless path.file?

      delete
      @path = path

      true
    end

    private

    # can create pid file?
    # @param [Pathname] path pid filepath
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

