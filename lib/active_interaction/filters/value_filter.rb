# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
    # @!method self.value(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are match (`==`) the value specified.
    #
    #   @!macro filter_method_params
    #   @option options [Object] :eq
    #     Value that this input should match using `==`
    #   @option options [Proc, Symbol] :converter Called when a new
    #     value is assigned to the value object. It should return a new value to be
    #     used. Any error thrown inside the converter is trapped
    #     and the value provided is treated as invalid. Any returned value that
    #     is not the correct class will also be treated as invalid.
    #
    #   @example
    #     value :action, eq: "update"
    #   @example
    #     value :action, eq: "update", converter: :downcase
  end

  # @private
  class ValueFilter < Filter
    register :value

    def initialize(name, options = {}, &block)
      unless options.key?(:eq)
        raise InvalidFilterError,
          'value filter requires :eq option to be specified'
      end

      if (converter = options[:converter])
        unless converter.respond_to?(:to_proc)
          raise InvalidConverterError, "#{converter.inspect} is not a valid converter"
        end

        @converter = converter.to_proc
      end

      super
    end

    private

    def matches?(value)
      options[:eq] == value
    end

    def convert(value)
      result = @converter ? @converter.call(value) : value

      if result.nil?
        [value, Filter::Error.new(self, :invalid_type)]
      else
        [result, nil]
      end
    rescue StandardError => e
      raise e if e.is_a?(InvalidConverterError)

      [value, Filter::Error.new(self, :invalid_type)]
    end
  end
end
