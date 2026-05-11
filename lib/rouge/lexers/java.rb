# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Java < RegexLexer
      title "Java"
      desc "The Java programming language (java.com)"

      tag 'java'
      filenames '*.java'
      mimetypes 'text/x-java'

      KEYWORDS = Set.new %w(
        assert break case catch continue default do else finally for
        if goto instanceof new return switch this throw try while
      )

      DECLARATIONS = Set.new %w(
        abstract const enum extends final implements native private protected
        public static strictfp super synchronized throws transient volatile
      )

      TYPES = Set.new %w(boolean byte char double float int long short var void String)

      id = /[[:alpha:]_][[:word:]]*/
      const_name = /[[:upper:]][[:upper:][:digit:]_]*\b/
      class_name = /[[:upper:]][[:alnum:]]*\b/

      state :root do
        rule %r/[^\S\n]+/, Text
        rule %r(//.*?$), Comment::Single
        rule %r(/\*.*?\*/)m, Comment::Multiline

        keywords %r/\w+/ do
          rule KEYWORDS, Keyword
        end

        rule %r/#{id}(?=\s*[(])/, Name::Function
        rule %r/#{id}:/, Name::Label

        keywords id do
          rule Set['class', 'interface', 'record'], Keyword::Declaration, :class
          rule Set['import', 'package'], Keyword::Namespace, :import
          rule DECLARATIONS, Keyword::Declaration
          rule TYPES, Keyword::Type
          rule Set['true', 'false', 'null'], Keyword::Constant
          default Name
        end

        rule %r/@#{id}/, Name::Decorator
        rule %r/"""\s*\n.*?(?<!\\)"""/m, Str::Heredoc
        rule %r/"(\\\\|\\"|[^"])*"/, Str
        rule %r/'(?:\\.|[^\\]|\\u[0-9a-f]{4})'/, Str::Char
        rule %r/(\.)(#{id})/ do
          groups Operator, Name::Attribute
        end

        rule const_name, Name::Constant
        rule class_name, Name::Class
        rule %r/\$?#{id}/, Name
        rule %r/[~^*!%&\[\](){}<>\|+=:;,.\/?-]/, Operator

        digit = /[0-9]_+[0-9]|[0-9]/
        bin_digit = /[01]_+[01]|[01]/
        oct_digit = /[0-7]_+[0-7]|[0-7]/
        hex_digit = /[0-9a-f]_+[0-9a-f]|[0-9a-f]/i
        rule %r/#{digit}+\.#{digit}+([eE]#{digit}+)?[fd]?/, Num::Float
        rule %r/0b#{bin_digit}+/i, Num::Bin
        rule %r/0x#{hex_digit}+/i, Num::Hex
        rule %r/0#{oct_digit}+/, Num::Oct
        rule %r/#{digit}+L?/, Num::Integer
        rule %r/\n/, Text
      end

      state :class do
        rule %r/\s+/m, Text
        rule id, Name::Class, :pop!
      end

      state :import do
        rule %r/\s+/m, Text
        rule %r/[a-z0-9_.]+\*?/i, Name::Namespace, :pop!
      end
    end
  end
end
