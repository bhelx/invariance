module Invariance
  class Invariant
    class PreCondition
      attr_reader :arg_n

      def initialize(arg_n, spec)
        @arg_n = arg_n
        @invariant = spec
      end

      def satisfies?(args)
        @invariant.call(args[@arg_n])
      end
    end

    class PostCondition
      def initialize(spec)
        @invariant = spec
      end

      def satisfies?(result, args)
        @invariant.call(result, args)
      end
    end
  end
end
