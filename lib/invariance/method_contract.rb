require "invariance/version"

module Invariance
  class MethodContract
    def initialize
      @pres = []
      @posts = []
      @method = nil
    end

    def apply_to(method)
      @method = method
    end

    def assert_preconditions!(args)
      errs = @pres.map do |pre|
        begin
          unless pre.satisfies? args
            "Argument #{args[pre.arg_n].inspect} at position #{pre.arg_n} not satisfied by #{pre.inspect}"
          end
        rescue => e
          e
        end
      end.compact
      if errs.any?
        raise Invariance::Error, "PreCondition failure: " + errs.join('; ')
      end
    end

    def assert_postconditions!(result, args)
      errs = @posts.map do |post|
        begin
          unless post.satisfies? result, args
            "Result #{result.inspect} not satisfied by #{post.inspect}"
          end
        rescue => e
          e
        end
      end.compact
      if errs.any?
        raise Invariance::Error, "PostCondition failure: " + errs.join('; ')
      end
    end

    def add_precondition(arg_n, spec=nil, &block)
      spec = block if block_given?
      @pres << Invariant::PreCondition.new(arg_n, spec)
    end

    def add_type_conditions(*args)
      if args.length == 1 && args.first.is_a?(Hash)
        spec = args.first
        argument_types = spec.keys.first
        return_type = spec.values.first
        argument_types.each_with_index do |t, arg_n|
          add_precondition arg_n, ->(x){ x.is_a?(t) }
        end
        add_postcondition(->(x, _args){ x.is_a?(return_type) })
      else
        args = args.first if args.first.is_a?(Array)
        args.each_with_index do |t, arg_n|
          add_precondition arg_n, ->(x){ x.is_a?(t) }
        end
      end
    end

    def has_preconditions?
      @pres.any?
    end

    def add_postcondition(spec=nil, &block)
      spec = block if block_given?
      @posts << Invariant::PostCondition.new(spec)
    end

    def has_postconditions?
      @posts.any?
    end
  end
end
