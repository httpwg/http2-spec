
HTTP/2 Draft Specifications
=============================

This is the working area for the [IETF HTTPbis Working
Group](http://trac.tools.ietf.org/wg/httpbis/trac/wiki) draft of
[HTTP/2](http://http2.github.io/).

HTTP/2 specification:
* [Editor's copy](http://http2.github.com/http2-spec/index.html) (HTML)
* [Editor's copy](http://http2.github.com/http2-spec/index.txt) (plain text)
* [Working Group Draft](http://tools.ietf.org/html/draft-ietf-httpbis-http2) (less recent, more official)

Header Compression (HPACK) specification:
* [Editor's copy](http://http2.github.com/http2-spec/compression.html) (HTML)
* [Editor's copy](http://http2.github.com/http2-spec/compression.txt) (plain text)
* [Working Group Draft](http://tools.ietf.org/html/draft-ietf-httpbis-header-compression) (less recent, more official)

Alternative Services specification:
* [Editor's copy](http://http2.github.com/http2-spec/alt-svc.html) (HTML)
* [Editor's copy](http://http2.github.com/http2-spec/alt-svc.txt) (plain text)
* [Working Group Draft](http://tools.ietf.org/html/draft-ietf-httpbis-alt-svc) (less recent, more official)


Contributing
------------

Before submitting feedback, please familiarize yourself with our current issues
list and review the [HTTP/2 page](http://http2.github.io/) and the [working
group home page](http://trac.tools.ietf.org/wg/httpbis/trac/wiki). If you're
new to this, you may also want to read the [Tao of the
IETF](http://www.ietf.org/tao.html).

Be aware that all contributions to the specification fall under the "NOTE WELL"
terms outlined below.

1. The best way to provide feedback (editorial or design) and ask questions is
sending an e-mail to [our mailing
list](http://lists.w3.org/Archives/Public/ietf-http-wg/). This will assure that
the entire Working Group sees your input in a timely fashion.

2. If you have **editorial** suggestions (i.e., those that do not change the
meaning of the specification), you can either:

  a) Fork this repository and submit a pull request; this is the lowest
  friction way to get editorial changes in.
  
  b) Submit a new issue to Github, and mention that you believe it is editorial
  in the issue body. It is not necessary to notify the mailing list for
  editorial issues.
  
  c) Make comments on individual commits in Github. Note that this feedback is
  processed only with best effort by the editors, so it should only be used for
  quick editorial suggestions or questions.

3. For non-editorial (i.e., **design**) issues, you can also create an issue on
Github. However, you **must notify the mailing list** when creating such issues,
providing a link to the issue in the message body.

  Note that **github issues are not for substantial discussions**; the only
  appropriate place to discuss design issues is on the mailing list itself.


Working With the Drafts
-----------------------

The source for our current draft is
[draft-ietf-httpbis-http2.xml](draft-ietf-httpbis-http2.xml), using the
[RFC2629 format](http://xml.resource.org/public/rfc/html/rfc2629.html).

If you're an editor, or forking a copy of the draft, a few things to know:

* Pushing to the master branch will automatically generate the HTML on the 
  gh-pages branch.
* You'll need xml2rfc, Java and Saxon-HE available. You can override the
  default locations in the environment.  On a Mac with
  [Homebrew](http://mxcl.github.io/homebrew/), "saxon-b" is the right package.
* Some of the make targets require GNU Make 4.0
* Making the txt and html for the latest drafts is done with "make".
* Output for a specific draft can be made using "make http2" or
  "make hpack".


NOTE WELL
---------

Any submission to the [IETF](http://www.ietf.org/) intended by the Contributor
for publication as all or part of an IETF Internet-Draft or RFC and any
statement made within the context of an IETF activity is considered an "IETF
Contribution". Such statements include oral statements in IETF sessions, as
well as written and electronic communications made at any time or place, which
are addressed to:

 * The IETF plenary session
 * The IESG, or any member thereof on behalf of the IESG
 * Any IETF mailing list, including the IETF list itself, any working group 
   or design team list, or any other list functioning under IETF auspices
 * Any IETF working group or portion thereof
 * Any Birds of a Feather (BOF) session
 * The IAB or any member thereof on behalf of the IAB
 * The RFC Editor or the Internet-Drafts function
 * All IETF Contributions are subject to the rules of 
   [RFC 5378](http://tools.ietf.org/html/rfc5378) and 
   [RFC 3979](http://tools.ietf.org/html/rfc3979) 
   (updated by [RFC 4879](http://tools.ietf.org/html/rfc4879)).

Statements made outside of an IETF session, mailing list or other function,
that are clearly not intended to be input to an IETF activity, group or
function, are not IETF Contributions in the context of this notice.

Please consult [RFC 5378](http://tools.ietf.org/html/rfc5378) and [RFC 
3979](http://tools.ietf.org/html/rfc3979) for details.

A participant in any IETF activity is deemed to accept all IETF rules of
process, as documented in Best Current Practices RFCs and IESG Statements.

A participant in any IETF activity acknowledges that written, audio and video
records of meetings may be made and may be available to the public.
