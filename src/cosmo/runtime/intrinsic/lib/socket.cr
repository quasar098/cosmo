require "socket"

module Cosmo::Intrinsic
  # TCP Socket Library
  class SocketLib < Lib
    def inject : Nil
      socket = {} of String => Hash(String, IFunction) | IFunction
      server = {} of String => IFunction
      server["listen"] = Server::Listen.new(@i)

      client = {} of String => IFunction
      client["connect"] = Client::Connect.new(@i)

      socket["Server"] = server;
      socket["Client"] = client;
      @i.declare_intrinsic("string->any", "Socket", socket)
    end

    abstract class Client::ContextFunctionBase < IFunction
      def initialize(interpreter : Interpreter, @sock : TCPSocket)
        super interpreter
      end
    end

    # Send data on the socket
    class Client::Connection::Send < Client::ContextFunctionBase
      def arity : Range(UInt32, UInt32)
        1.to_u .. 1.to_u
      end

      def call(args : Array(ValueType)) : Nil
        TypeChecker.assert("string", args.first, token("Socket::Client::Connection->send"))
        @sock.puts args.first
      end
    end

    # Receive data on the socket
    class Client::Connection::Receive < Client::ContextFunctionBase
      def arity : Range(UInt32, UInt32)
        0.to_u .. 0.to_u
      end

      def call(args : Array(ValueType)) : (String | Nil)
        return @sock.gets
      end
    end

    # Close the socket client
    class Client::Connection::Close < Client::ContextFunctionBase
      def arity : Range(UInt32, UInt32)
        0.to_u .. 0.to_u
      end

      def call(args : Array(ValueType)) : Nil
        @sock.close
      end
    end

    # Connect to another server and return the hash containing basic socket utility functions for the socket
    class Client::Connect < IFunction
      def arity : Range(UInt32, UInt32)
        2.to_u .. 2.to_u
      end

      def call(args : Array(ValueType)) : ValueType | Nil
        TypeChecker.assert("string", args.first, token("Socket::Client->connect"))
        TypeChecker.assert("uint", args[1], token("Socket::Client->connect"))

        port = args[1].as(Int).to_i32
        client = TCPSocket.new(args[0].to_s, port, blocking=true)

        wrapped_conn = {} of String => Client::ContextFunctionBase
        wrapped_conn["send"] = Client::Connection::Send.new(@interpreter, client)
        wrapped_conn["recv"] = Client::Connection::Receive.new(@interpreter, client)
        wrapped_conn["close"] = Client::Connection::Close.new(@interpreter, client)

        return TypeChecker.hash_as_value_type(wrapped_conn)
      end
    end

    abstract class Server::ContextFunctionBase < IFunction
      def initialize(interpreter : Interpreter, @sock : TCPSocket)
        super interpreter
      end
    end

    # Send socket data
    class Server::Connection::Send < Server::ContextFunctionBase
      def arity : Range(UInt32, UInt32)
        1.to_u .. 1.to_u
      end

      def call(args : Array(ValueType)) : Nil
        TypeChecker.assert("string", args.first, token("Socket::Server::Connection->send"))
        @sock.puts args.first
      end
    end

    # Receive socket data
    class Server::Connection::Receive < Server::ContextFunctionBase
      def arity : Range(UInt32, UInt32)
        1.to_u .. 1.to_u
      end

      def call(args : Array(ValueType)) : (String | Nil)
        TypeChecker.assert("string", args.first, token("Socket::Server::Connection->recv"))
        @sock.print args.first
        return @sock.gets
      end
    end

    # Close socket but not the server
    class Server::Connection::Close < Server::ContextFunctionBase
      def arity : Range(UInt32, UInt32)
        0.to_u .. 0.to_u
      end

      def call(args : Array(ValueType)) : Nil
        @sock.close
      end
    end

    # Listen for incoming connections. This will call the callback argument and prevent any further code from running.
    class Server::Listen < IFunction
      def arity : Range(UInt32, UInt32)
        2.to_u .. 2.to_u
      end

      def call(args : Array(ValueType)) : Nil
        TypeChecker.assert("uint", args.first, token("Socket::Server->listen"))
        TypeChecker.assert("Function", args[1], token("Socket::Server->listen"))

        port = args.first.as(Int).to_i32
        tcpserver = TCPServer.new("0.0.0.0", port)
        while client = tcpserver.accept?
          wrapped_conn = {} of String => Server::ContextFunctionBase
          wrapped_conn["send"] = Server::Connection::Send.new(@interpreter, client)
          wrapped_conn["recv"] = Server::Connection::Receive.new(@interpreter, client)
          wrapped_conn["close"] = Server::Connection::Close.new(@interpreter, client)
          spawn do
            args[1].as(Function).call([
              TypeChecker.hash_as_value_type(wrapped_conn)
            ])
          end
        end
      end
    end
  end
end
