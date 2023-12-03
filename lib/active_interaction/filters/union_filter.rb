# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
    # @!method self.object(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are the correct class.
    #
    #   @!macro filter_method_params
    #   @option options [Class, String, Symbol] :class (use the attribute name)
    #     Class name used to ensure the value.
    #   @option options [Proc, Symbol] :converter A symbol specifying the name
    #     of a class method of `:class` or a Proc that is called when a new
    #     value is assigned to the value object. The converter is passed the
    #     single value that is used in the assignment and is only called if the
    #     new value is not an instance of `:class`. The class method or proc
    #     are passed the value. Any error thrown inside the converter is trapped
    #     and the value provided is treated as invalid. Any returned value that
    #     is not the correct class will also be treated as invalid.
    #
    #   @example
    #     object :account
    #   @example
    #     object :account, class: User
  end

  # @private
  class UnionFilter < Filter
    include Missable

    # The array starts with the class override key and then contains any
    # additional options which halt explicit setting of the class.
    FILTER_NAME_OR_OPTION = {
      'ActiveInteraction::ObjectFilter' => [:class].freeze,
      'ActiveInteraction::RecordFilter' => [:class].freeze,
      'ActiveInteraction::InterfaceFilter' => %i[from methods].freeze
    }.freeze
    private_constant :FILTER_NAME_OR_OPTION

    register :union

    def process(value, context)
      value, error = cast(value, context)
      return Input.new(self, value: value, error: error) if error

      # either we found a filter during matches?,
      if @matched_filter
        @matched_filter.process(super, context)
      else # or we are dealing with the default value
        Input.new(self, value: value)
      end
    end

    private

    def matches?(value)
      @matched_filter = find_filter(value)
      !!@matched_filter
    rescue NoMethodError
      false
    end

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(*, &block)
      super do |klass, names, options|
        options = add_option_in_place_of_name(klass, options)

        filter = klass.new(names.first || '', options, &block)

        filters[filters.size.to_s.to_sym] = filter

        validate!(names)
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

    def add_option_in_place_of_name(klass, options)
      if (keys = FILTER_NAME_OR_OPTION[klass.to_s]) && (keys & options.keys).empty?
        options.merge(
          "#{keys.first}": name.to_s.singularize.camelize.to_sym
        )
      else
        options
      end
    end

    # @param filter [Filter]
    # @param names [Array<Symbol>]
    #
    # @raise [InvalidFilterError]
    def validate!(names)
      raise InvalidFilterError, 'attribute names in array block' unless names.empty?

      nil
    end

    def matched_filter_or_find(value)
      @matched_filter || find_filter(value)
    end

    def find_filter(value)
      filters.find { |filter| filter.matches?(value) }
    end
  end
end
