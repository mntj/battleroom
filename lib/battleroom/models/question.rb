class Question
  attr_reader   :data, :variable_name, :variable_value, :evaluation_scope
  attr_accessor :answer_value, :input_mechanism, :user_input

  def initialize(evaluation_scope)
    @evaluation_scope = evaluation_scope
    @data             = self.class.generate_question
    @variable_name    = rotate_array(data[:possible_variable_names] || []).first
    @input_mechanism  = 'readline'
    post_initialize
  end

  def post_initialize
    nil
  end

  # avoids immediate re-sampling of questions
  def self.generate_question
    # calls upon *class instance* variable assigned in the subclasses
    question = @questions.shift
    @questions.push(question)
    question
  end

  def congratulation_sequence(duration)
    print_congratulation
    sleep(duration)
    clear_display
  end

  def handle_syntax_error_exceptions(error)
    if error.message.match /unexpected end-of-input/
      print_unexpected_end_of_input_explanation(error)
    elsif error.message.include?('unterminated string meets end of file')
      battleprint 'Blurg! You neglected to provide closing quotes for your string. Try again!'.red
    end
  end

  def get_input
    if input_mechanism == 'readline'
      Readline.readline('> '.blue, true).chomp
    else
      Pry.start_without_pry_byebug(evaluation_scope)
      $input.chomp
    end
  end

  # def naughty_input?
  #   if user_input.match(/(require|`|binding)/)
  #     battleprint "No way no how! Try again.\n".red
  #     true
  #   else
  #     false
  #   end
  # end

  def enter_evaluation_loop(&block)
    answered_correctly = false
    until answered_correctly
      begin
        self.user_input = get_input
        abort('Goodbye!'.green) if user_input.match(/^(q|exit|!!!\s?)\z/i)
        if !naughty_input?(user_input) && yield
          congratulation_sequence(1.6)
          answered_correctly = true
        end
      rescue SyntaxError => e
        handle_syntax_error_exceptions(e)
      end
    end
  end

end # Question
