require 'chef_compat/copied_from_chef'
class Chef
module ::ChefCompat
module CopiedFromChef
require 'chef_compat/copied_from_chef/chef/resource/action_class'
require 'chef_compat/copied_from_chef/chef/provider'
require 'chef_compat/copied_from_chef/chef/mixin/properties'
class Chef < (defined?(::Chef) ? ::Chef : Object)
  class Resource < (defined?(::Chef::Resource) ? ::Chef::Resource : Object)
    include Chef::Mixin::Properties
    property :name, String, coerce: proc { |v| v.is_a?(Array) ? v.join(', ') : v.to_s }, desired_state: false
    def initialize(name, run_context=nil)
super if defined?(::Chef::Resource)
      name(name) unless name.nil?
      @run_context = run_context
      @noop = nil
      @before = nil
      @params = Hash.new
      @provider = nil
      @allowed_actions = self.class.allowed_actions.to_a
      @action = self.class.default_action
      @updated = false
      @updated_by_last_action = false
      @supports = {}
      @ignore_failure = false
      @retries = 0
      @retry_delay = 2
      @not_if = []
      @only_if = []
      @source_line = nil
      # We would like to raise an error when the user gives us a guard
      # interpreter and a ruby_block to the guard. In order to achieve this
      # we need to understand when the user overrides the default guard
      # interpreter. Therefore we store the default separately in a different
      # attribute.
      @guard_interpreter = nil
      @default_guard_interpreter = :default
      @elapsed_time = 0
      @sensitive = false
    end
    def action(arg=nil)
      if arg
        arg = Array(arg).map(&:to_sym)
        arg.each do |action|
          validate(
            { action: action },
            { action: { kind_of: Symbol, equal_to: allowed_actions } }
          )
        end
        @action = arg
      else
        @action
      end
    end
    alias_method :action=, :action
    def state_for_resource_reporter
      state = {}
      state_properties = self.class.state_properties
      state_properties.each do |property|
        if property.identity? || property.is_set?(self)
          state[property.name] = send(property.name)
        end
      end
      state
    end
    alias_method :state, :state_for_resource_reporter
    def identity
      result = {}
      identity_properties = self.class.identity_properties
      identity_properties.each do |property|
        result[property.name] = send(property.name)
      end
      return result.values.first if identity_properties.size == 1
      result
    end
    def to_hash
      # Grab all current state, then any other ivars (backcompat)
      result = {}
      self.class.state_properties.each do |p|
        result[p.name] = p.get(self)
      end
      safe_ivars = instance_variables.map { |ivar| ivar.to_sym } - FORBIDDEN_IVARS
      safe_ivars.each do |iv|
        key = iv.to_s.sub(/^@/,'').to_sym
        next if result.has_key?(key)
        result[key] = instance_variable_get(iv)
      end
      result
    end
    def self.identity_property(name=nil)
      result = identity_properties(*Array(name))
      if result.size > 1
        raise Chef::Exceptions::MultipleIdentityError, "identity_property cannot be called on an object with more than one identity property (#{result.map { |r| r.name }.join(", ")})."
      end
      result.first
    end
    attr_accessor :allowed_actions
    def allowed_actions(value=NOT_PASSED)
      if value != NOT_PASSED
        self.allowed_actions = value
      end
      @allowed_actions
    end
    def resource_name
      @resource_name || self.class.resource_name
    end
    def self.use_automatic_resource_name
      automatic_name = convert_to_snake_case(self.name.split('::')[-1])
      resource_name automatic_name
    end
    def self.allowed_actions(*actions)
      @allowed_actions ||=
        if superclass.respond_to?(:allowed_actions)
          superclass.allowed_actions.dup
        else
          [ :nothing ]
        end
      @allowed_actions |= actions.flatten
    end
    def self.allowed_actions=(value)
      @allowed_actions = value.uniq
    end
    def self.default_action(action_name=NOT_PASSED)
      unless action_name.equal?(NOT_PASSED)
        @default_action = Array(action_name).map(&:to_sym)
        self.allowed_actions |= @default_action
      end

      if @default_action
        @default_action
      elsif superclass.respond_to?(:default_action)
        superclass.default_action
      else
        [:nothing]
      end
    end
    def self.default_action=(action_name)
      default_action action_name
    end
    def self.action(action, &recipe_block)
      action = action.to_sym
      declare_action_class
      action_class.action(action, &recipe_block)
      self.allowed_actions += [ action ]
      default_action action if Array(default_action) == [:nothing]
    end
    def self.load_current_value(&load_block)
      define_method(:load_current_value!, &load_block)
    end
    def current_value_does_not_exist!
      raise Chef::Exceptions::CurrentValueDoesNotExist
    end
    def self.action_class
      @action_class ||
        # If the superclass needed one, then we need one as well.
        if superclass.respond_to?(:action_class) && superclass.action_class
          declare_action_class
        end
    end
    def self.declare_action_class
      return @action_class if @action_class

      if superclass.respond_to?(:action_class)
        base_provider = superclass.action_class
      end
      base_provider ||= Chef::Provider

      resource_class = self
      @action_class = Class.new(base_provider) do
        include ActionClass
        self.resource_class = resource_class
      end
    end
    FORBIDDEN_IVARS = [:@run_context, :@not_if, :@only_if, :@enclosing_provider]
    HIDDEN_IVARS = [:@allowed_actions, :@resource_name, :@source_line, :@run_context, :@name, :@not_if, :@only_if, :@elapsed_time, :@enclosing_provider]
    class << self
    end
    @@sorted_descendants = nil
    private
  end
end
end
end
end
