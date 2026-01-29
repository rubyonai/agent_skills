# frozen_string_literal: true

module AgentSkills
  class Error < StandardError; end

  class NotFoundError < Error; end

  class ParseError < Error; end

  class ValidationError < Error; end
end
