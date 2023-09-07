Definitions.

PROPERTY    = [a-z-]+\s*:[a-z0-9\s"'(),#]+;
BEGIN_SCOPE = [.&]+[a-z\s-,.:&]*{
END_SCOPE   = }
WHITESPACE  = [\s\t\n\r]

Rules.

{PROPERTY}    : {token, {property, TokenLine, extract_property(TokenChars)}}.
{BEGIN_SCOPE} : {token, {start_scope, TokenLine, extract_begin_selector(TokenChars)}}.
{END_SCOPE}   : {token, {end_scope, TokenLine}}.
{WHITESPACE}  : skip_token.

Erlang code.

extract_property(Chars) -> 
  C1 = list_to_binary(Chars),
  C2 = string:replace(C1, ";", ""),
  C3 = string:strip(C2),
  [Property, Value] = string:split(C3, ":"),
  {string:trim(Property, both), string:trim(Value, both)}.

extract_begin_selector(Chars) ->
  C1 = list_to_binary(Chars),
  C2 = string:replace(C1, "{", ""),
  string:trim(C2).
