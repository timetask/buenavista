Definitions.

APPLY       = \@apply[a-z0-9-\s"'()\[\],#]+;
PROPERTY    = [a-z-]+\s*:[a-z0-9\s/"'(),#<>%=@_\-:\.!]+;
BEGIN_SCOPE = [\[.&*]+[a-z\s,.:&-_\"<>%=()\[\]]+{
END_SCOPE   = }
WHITESPACE  = [\s\t\n\r]

Rules.

{PROPERTY}    : {token, {property, TokenLine, extract_property(TokenChars)}}.
{APPLY}       : {token, {apply, TokenLine, extract_apply(TokenChars)}}.
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

extract_apply(Chars) ->
  C1 = list_to_binary(Chars),
  C2 = string:replace(C1, ";", ""),
  C3 = string:replace(C2, "@apply", ""),
  string:trim(C3).
