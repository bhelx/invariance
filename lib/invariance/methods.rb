require "invariance/method_contract"
require "invariance/invariant"

module Invariance
  module Methods
    def method_added(meth)
      return unless defined?(@_pending_contract) && !@recursing

      @recursing = true # protect against infinite recursion
      @contracts ||= {}

      contract = @contracts[meth] = @_pending_contract
      contract.apply_to meth
      old_meth = instance_method(meth)
      define_method(meth) do |*args, &block|
        if contract.has_preconditions?
          contract.assert_preconditions!(args)
        end
        result = old_meth.bind(self).call(*args, &block)
        if contract.has_postconditions?
          contract.assert_postconditions!(result, args)
        end
        result
      end

      @_pending_contract = nil
      @recursing = nil
    end

    def pre(arg_n, spec=nil, &block)
      @_pending_contract ||= MethodContract.new
      @_pending_contract.add_precondition(arg_n, spec, &block)
    end

    def post(spec=nil, &block)
      @_pending_contract ||= MethodContract.new
      @_pending_contract.add_postcondition(spec, &block)
    end

    def types(*args)
      @_pending_contract ||= MethodContract.new
      @_pending_contract.add_type_conditions(*args)
    end
  end
end
