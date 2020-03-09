# frozen_string_literal: true

class LifestyleCalculator < ApplicationRecord
  def calculate(answers)
    calculator = Dentaku::Calculator.new
    calculator.store(translate_answer_values(answers))

    [:housing, :food, :car, :flights, :other].map do |category|
      # TODO: Test raising of errors
      [
        category,
        GreenhouseGases.new(calculator.evaluate!(send("#{category}_formula")).to_i || 0)
      ]
    end.to_h
  end

  private

  def translate_answer_values(answers)
    values = answers.dup

    [:region, :home, :heating, :house_age, :green_electricity, :food, :car_type].each do |question|
      options = send("#{question}_options")

      option = options[answers[question]] if options&.any?
      value = (BigDecimal(option) if option.present?) || 0 # TODO: Test this
      values[question] = value
      values["#{question}_answer".to_sym] = answers[question]
    end

    values
  end
end