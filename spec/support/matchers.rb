RSpec::Matchers.define :have_input_error do |expected_type|
  match do |input|
    input.errors.any? do |error|
      error.is_a?(ActiveInteraction::Filter::Error) &&
        error.type == expected_type
    end
  end

  failure_message do |input|
    msg = "expected that input have errors of type #{expected_type.inspect}. "
    if input&.errors&.any?
      msg += "Got: \n"
      msg += input.errors.map(&:inspect).inspect
    else
      msg += 'Got no errors.'
    end
    msg
  end
end

RSpec::Matchers.define :be_sucessful do |**args|
  value_expected = args.key?(:value)
  expected_value = args[:value]

  match do |input|
    input.errors.none? && (!value_expected || expected_value == input.value)
  end

  failure_message do |input|
    msg = ''
    if input.errors.any?
      msg += "Expected that input have no errors. Got error(s): \n"
      msg += input.errors.map(&:inspect).inspect
    end
    if value_expected && expected_value != input.value
      msg += "Expected input value #{input.value.inspect} to be == #{expected_value.inspect}"
    end
    msg
  end
end
