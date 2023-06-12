require "file"

module Cosmo
  module Intrinsic
    class FileLib < Lib
      def inject : Nil
        file = {} of String => IFunction
        file["read"] = Read.new(@i)
        file["write"] = Write.new(@i)
        file["append"] = Append.new(@i)
        file["delete"] = Delete.new(@i)
        file["exists?"] = Exists.new(@i)
        file["directory?"] = Directory.new(@i)
        file["empty?"] = Empty.new(@i)

        @i.declare_intrinsic("string->Function", "File", file)
      end

      class Empty < IFunction
        def arity : Range(UInt32, UInt32)
          1.to_u .. 1.to_u
        end

        def call(args : Array(ValueType)) : Bool
          begin
            File.empty?(args.first.to_s)
          rescue File::NotFoundError
            Logger.report_error("Failed to read from file", "File '#{args.first.to_s}' could not be found", token("File->empty?"))
          end
        end
      end

      class Directory < IFunction
        def arity : Range(UInt32, UInt32)
          1.to_u .. 1.to_u
        end

        def call(args : Array(ValueType)) : Bool
          File.directory?(args.first.to_s)
        end
      end

      class Exists < IFunction
        def arity : Range(UInt32, UInt32)
          1.to_u .. 1.to_u
        end

        def call(args : Array(ValueType)) : Bool
          File.exists?(args.first.to_s)
        end
      end

      class Delete < IFunction
        def arity : Range(UInt32, UInt32)
          1.to_u .. 1.to_u
        end

        def call(args : Array(ValueType)) : Nil

          begin
            File.delete(args.first.to_s)
          rescue File::NotFoundError
            Logger.report_error("Failed to delete file", "File '#{args.first.to_s}' could not be found", token("File->delete"))
          end
        end
      end

      class Append < IFunction
        def arity : Range(UInt32, UInt32)
          2.to_u .. 2.to_u
        end

        def call(args : Array(ValueType)) : Nil
          begin
            File.write(args.first.to_s, args[1].to_s, mode: "a")
          rescue File::NotFoundError
            Logger.report_error("Failed to append to file", "File '#{args.first.to_s}' could not be found", token("File->append"))
          end
        end
      end

      class Write < IFunction
        def arity : Range(UInt32, UInt32)
          2.to_u .. 2.to_u
        end

        def call(args : Array(ValueType)) : Nil
          begin
            File.write(args.first.to_s, args[1].to_s)
          rescue File::NotFoundError
            Logger.report_error("Failed to write to file", "File '#{args.first.to_s}' could not be found", token("File->append"))
          end
        end
      end

      class Read < IFunction
        def arity : Range(UInt32, UInt32)
          1.to_u .. 1.to_u
        end

        def call(args : Array(ValueType)) : String
          begin
            File.read(args.first.to_s)
          rescue File::NotFoundError
            Logger.report_error("Failed to read from file", "File '#{args.first.to_s}' could not be found", token("File->append"))
          end
        end
      end
    end
  end
end
