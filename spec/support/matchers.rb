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
