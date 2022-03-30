# frozen_string_literal: true

class PostQuery
  extend Memoist

  attr_reader :search, :parser, :ast
  delegate :tag_names, :metatags, to: :ast

  def initialize(search)
    @search = search
    @parser = Parser.new(search)
    @ast = parser.parse.simplify
  end

  def tags
    Tag.where(name: tag_names)
  end

  # True if this search would return all posts (normally because the search is the empty string).
  def is_empty_search?
    ast.all?
  end

  # True if this search would return nothing (normally because there was a syntax error).
  def is_null_search?
    ast.none?
  end

  def is_single_tag?
    ast.tag?
  end

  def select_metatags(*names)
    metatags.select { |metatag| metatag.name.in?(names.map(&:to_s).map(&:downcase)) }
  end

  def has_metatag?(*names)
    select_metatags(*names).present?
  end

  def find_metatag(*names)
    select_metatags(*names).first&.value
  end

  memoize :tags
end
