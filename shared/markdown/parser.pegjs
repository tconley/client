{
  const linkExp = new RegExp(/(?:(?:ftp|http(?:s)?)?:\/\/.)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b(?:[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)\b/i)
  const protoExp = new RegExp(/^([a-z]*):\/\//i)
  const dotDotExp = new RegExp(/[^/]\.\.[^/]/)
  const mailToExp = new RegExp(/^mailto:/i)
  // Instead of encoding all the bad cases into a more complicated regexp lets just add some simple code here
  // Note: We aren't trying to be 100% perfect here, just getting something that works pretty good and pretty quickly
  function goodLink (link, protocolMatch) {
    return !link.match(dotDotExp) && // disallow 'a...b', but allow /../
      !link.match(mailToExp) && // disallow mailto:
      (!protocolMatch || ['http://', 'https://'].includes(protocolMatch[0].toLowerCase())) // only allow http(s)
  }

  function convertLink (text) {
    const matches = text.match(linkExp)
    if (matches) {
      const match = matches[0]
      const protocolMatch = match.match(protoExp)
      if (goodLink(match, protocolMatch)) {
        const href = protocolMatch && match || 'http://' + match
        const start = matches.index
        const end = start + match.length
        const left = text.substring(0, start)
        const right = text.substring(start + end)
        return {
          type: 'text',
          children: [
            ...(left ? [left] : []),
            {type: 'link', children: [match], href},
            ...(right ? [right] : []),
          ],
        }
      }
    }
    return text
  }
}

start
 = children:(Blank / Code / Content / Blank)* { return {type: 'text', children} }

Code = CodeBlock / InlineCode

Content
 = StyledText / Text

StyledText
 = QuoteBlock / Italic / Bold / Strike / Emoji

// Define what our markers look like
Ticks1 = "`" ! '`'
Ticks3 = __? "```" __? ! '```'

StrikeMarker = "~" ! "~"
BoldMarker = "*" ! "*"
ItalicMarker = "_" ! "_"
EmojiMarker = ":" ! ":"
QuoteBlockMarker = ">"

// Define what we can go to when we are inside a style. e.g. Bold -> Bold doesn't make sense, but Bold -> Strike does
FromBold
 = Italic / Strike / InsideBoldMarker

FromItalic
 = Bold / Strike / InsideItalicMarker

FromStrike
 = Italic / Bold / InsideStrikeMarker

FromQuote
 = Italic / Bold / Strike / InsideQuoteBlock

// Define what text inside a style looks like. Usually everything but the end marker
InsideBoldMarker
 = (! BoldMarker .) { return text() }

InsideItalicMarker
 = (! ItalicMarker .) { return text() }

InsideStrikeMarker
 = (! StrikeMarker .) { return text() }

InsideCodeBlock
 = (! Ticks3 .) { return text() }

InsideInlineCode
 = (! Ticks1 .) { return text() }

InsideQuoteBlock
 = (! LineTerminatorSequence .) { return text() }

// Here we use the literal ":" because we want to not match the :foo in ::foo
InsideEmojiMarker
 = !EmojiMarker [a-zA-Z0-9+_-] { return text() }

InsideEmojiTone
 = "::skin-tone-" [1-6] { return text() }

Emoji
 = EmojiMarker children:InsideEmojiMarker+ tone:InsideEmojiTone? ":" { return {type: 'emoji', children: [children.join('') + (tone || '')]} }

Blank
 = (WhiteSpace / LineTerminatorSequence) { return text() }

NonBlank
 = !(WhiteSpace / LineTerminatorSequence) char:. { return char }

_
 = (WhiteSpace)*

__
 = (WhiteSpace / LineTerminatorSequence)*

WhiteSpace
 = [\t\v\f \u00A0\uFEFF] / Space

LineTerminatorSequence "end of line"
 = "\n"
 / "\r\n"
 / "\r"
 / "\u2028" // line spearator
 / "\u2029" // paragraph separator

Space
 = [\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000]
