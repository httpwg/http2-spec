---
title: Opportunistic Encryption for HTTP URIs
abbrev: Opportunistic HTTP Encryption
docname: draft-nottingham-http2-encryption-00
date: 2013
category: std

ipr: trust200902
area: General
workgroup: 
keyword: Internet-Draft

stand_alone: yes
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
 -
    ins: M. Nottingham
    name: Mark Nottingham
    organization: 
    email: mnot@mnot.net
    uri: http://www.mnot.net/

normative:
  RFC2119:
  RFC2818:
  RFC5246:
  I-D.ietf-httpbis-http2:
  I-D.ietf-httpbis-p1-messaging:

informative:
  firesheep:
    target: http://codebutler.com/firesheep/
    title: Firesheep
    author:
      ins: E. Butler
      name: Eric Butler
    date: 2010
  streetview:
    target: http://www.wired.com/threatlevel/2012/05/google-wifi-fcc-investigation/
    title: The Anatomy of Google's Wi-Fi Sniffing Debacle
    author:
      ins: D. Kravets
      name: David Kravets
      organization: Wired
    date: 2012
  xkeyscore:
    target: http://www.theguardian.com/world/2013/jul/31/nsa-top-secret-program-online-data
    title: NSA tool collects 'nearly everything a user does on the internet'
    author:
      ins: G. Greenwald
      name: Glenn Greenwald
      organization: The Guardian
    date: 2013
  I-D.mbelshe-httpbis-spdy:
  RFC2804:
  RFC3365:
  RFC6265:
  RFC6962:
  RFC6973:


--- abstract

This document proposes a way to optimistically encrypt HTTP/2.0 using TLS for
HTTP URIs.

--- middle

# Introduction

In discussion at IETF87, it was proposed that the current means of
bootstrapping encryption in HTTP {{I-D.ietf-httpbis-p1-messaging}} -- using the
"HTTPS" URI scheme -- unintentionally gives the server disproportionate power
in determining whether encryption is used.

Furthermore, HTTP's current use of TLS {{RFC5246}} for "https://" URIs is
inflexible; it is difficult to introduce new trust roots, for example.

This document proposes changes to HTTP that decouple the URI scheme from the
use and configuration of underlying encryption, as well as other aspects of the
protocol.

In particular, it defines the concept of an "alternate service" that allows an
origin to advertise when its resources are available at a separate location,
using a different configuration of protocols.

This allows a "http://" URI to be upgraded to use TLS optimistically. 

Because deploying TLS requires acquiring and configuring a valid certificate,
some deployments may find supporting it difficult. Therefore, this document
also specifies a "relaxed" profile of HTTP/2.0 over TLS that does not require
strong server authentication, specifically for use with "http://" URIs.

Note: This is a preliminary draft that attempts to capture the state of
relevant discussion to this point. It has not be reviewed for security,
deployability, or effectiveness, and is only intended to serve as the basis of
further discussion in the HTTPbis Working Group.

## Goals and Non-Goals

This proposal attempts to de-couple a HTTP URI's scheme from the specific wire
protocol in use, as well as that protocol's layering onto the network.

The immediate goal is to make HTTP URIs more robust in the face of passive
monitoring.

Such passive attacks are often opportunistic; they rely on sensitive
information being available in the clear. Furthermore, they are often broad,
where all available data is collected en masse, being analyzed separately for
relevant information.

It is not a goal of this document to address active or targeted attacks,
although future solutions may be complementary.

Other goals include ease of implementation and deployment, with minimal impact
upon performance (in keeping with the goals of HTTP/2.0).

Furthermore, since this proposal is designed as an alternate negotiation
mechanism for HTTP/2.0, it is expected that it is useful for that use case as
well.

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.



## HTTP-related Protocol Identifiers

To accommodate this approach, HTTP/2.0 will need to nominate several protocol
negotiation strings (a.k.a. "profiles") to allow negotiation for the desired
properties in alternate services.

This might include:

* http1 - http/1.x over TCP
* http1-tls - http/1.x over TLS over TCP (as per {{RFC2818}})
* http2 - http/2.x over TCP
* http2-tls - http/2.x over TLS over TCP (as per {{RFC2818}})
* http2-tls-relaxed - http/2.x over TLS over TCP (see below)

Most of these are already latently defined by HTTP/2.0, with the exception being http2-tls-relaxed, defined below.

These profiles are expected to be used not only in the Alt-Svc header field,
but also in other HTTP/2.0 negotiation mechanisms; e.g., ALPN, the "Upgrade
dance" and so forth.

Note that, as discussed in Security Considerations, there may be situations
(e.g,. ALPN) where advertising some of these profiles are inapplicable or
inadvisable.

For example, in an ALPN negotiation for a "https://" URI, it is only sensible
to offer http1-tls and http2-tls.


### The "http2-tls-relaxed" Protocol

Servers that support the "http2-tls-relaxed" protocol indicate that they
support TLS for access to URIs with the "http" URI scheme using HTTP/2.0 or
greater.

Servers MAY advertise the "http2-tls-relaxed" profile for resources with a
"http" origin scheme; they MUST NOT advertise it for resources with a "https"
origin.

When a client connects to an "http2-tls-relaxed" alternate service, it MUST use
TLS1.1 or greater, and MUST use HTTP/2.x. HTTP/2.0 SHOULD be used as
soon as TLS negotiation is completed; i.e., the "Upgrade dance" SHOULD NOT be
performed.

When connecting to an "http2-tls-relaxed" service, the algorithm for
authenticating the server described in {{RFC2818}} Section 3.1 changes; the
client does not necessarily validate its certificate for expiry, hostname match
or relationship to a known certificate authority (as it would with "normal"
HTTPS).

However, the client MAY perform additional checks on the certificate and make a
decision as to its validity before using the server. Definition of such
additional checks are out of scope for this specification.

Upon initial adoption of this proposal, it is expected that no such additional
checks will be performed. Therefore, the client MUST NOT use the
"http2-tls-relaxed" profile to connect to alternate services whose host does
not match that of the origin, unless additional checks are performed.

This requirement bounds the risk of a service being hijacked and redirected to
another host; see Security Considerations for details.

[[TODO: define "match"]]

Servers SHOULD use the same certificate consistently over time, to aid future
extensions for building trust and adding other services.

[[TODO: define "same"; likely not the same actual certificate. ]]

When the http2-tls-relaxed protocol is in use, User Agents MUST NOT indicate
the connection has the same level of security as https:// (e.g. using a "lock
device").



# Security Considerations

## Alt-Svc Header Field Downgrade Attacks

Because the Alt-Svc header field appears in the clear (for "http://" URIs), it
is subject to downgrade by attackers that are able to Man-in-the-Middle the
network connection; in its simplest form, an attacker that wants the connection
to remain in the clear need only strip the Alt-Svc header from responses.

This proposal does not offer a remedy for this risk. However, it's important to
note that it is no worse than current use of unencrypted HTTP in the face of
such active attacks.


## Poor Client Profile Choices

Furthermore, because different protocols can have different security
properties, clients ought not blindly use alternate services, but instead they
option(s) presented for conformance to implementation policy, user preferences,
and general security. 

For example, in theory the header field could be used to advertise a downgrade
to plain TCP from a TLS-protected connection, or to relax certificate checks
for a HTTPS URI; opting to use such an alternate would seldom be desirable.


## Alt-Svc Header Field Hijacking

An attacker local to the Web server who can inject response header fields can
redirect HTTP traffic to a different port on the same host using the
"http2-tls-relaxed" protocol; if it is under their control, the can masquerade
as the HTTP server.

An attacker local to the Web server who can inject response header fields can
redirect HTTP traffic to an arbitrary host and port using the "http2-tls"
protocol; if they can present a certificate which validates for the host under
attack, they can masquerade as that server.

Both of these risks can be mitigated by appropriate controls to setting
response header fields, as well as control over who can open a port for
listening (in the former case) and good certificate hygiene (in the latter
case).

An attacker who can Man-in-the-Middle the network connection and inject
response header fields directly can redirect HTTP traffic to a different port
and (presumably) masquerade as that server.

As with HTTP today, it is not possible to mitigate this latter risk without
cryptographic solutions.

## Alt-Svc Header Field "Gap"

When the Alt-Svc header field is used in "http://" URIs, the client needs to
send an unencrypted HTTP request to the server to discover the alternates. In
doing so, it potentially exposes sensitive information (e.g., cookies
{{RFC6265}}) to surveillance.

This risk can be mitigated if the client is willing to send a separate request
(e.g., OPTIONS *) to the origin to discover policy before making requests
containing potentially sensitive information. However, doing so adds a
round-trip of latency to such requests.

Likewise, if the Alt-Svc is cacheable for a long period (using a large ma
parameter), it reduces the window for such attacks (but does not eliminate it).

Alternatively, this risk can be mitigated by using an out-of-band discovery
mechanism (e.g., DNS).


--- back

# Acknowledgements

Thanks to Patrick McManus, Eliot Lear, Stephen Farrell, Guy Podjarny, Stephen
Ludin, Erik Nygren, Paul Hoffman and Adam Langley for their feedback and
suggestions.


# Recent History and Background

One of the design goals for SPDY {{I-D.mbelshe-httpbis-spdy}} was increasing
the use of encryption on the Web, achieved by only supporting the protocol over
a connection protected by TLS {{RFC5246}}.

This was done, in part, because sensitive information -- including not only
login credentials, but also personally identifying information (PII) and even
patterns of access -- are increasingly prevalent on the Web, being evident in
potentially every HTTP request made. 

Attacks such as FireSheep {{firesheep}} showed how easy it is to gather such
information when it is sent in the clear, and incidents such as Google's
collection of unencrypted data by its StreetView Cars {{streetview}} further
illustrated the risks.

In adopting SPDY as the basis of HTTP/2 {{I-D.ietf-httpbis-http2}}, the HTTPbis
Working Group agreed not to make TLS mandatory to implement (MtI) or mandatory
to use (MtU) in our charter, despite an IETF policy to prefer the "best
security available" {{RFC3365}}.

There were a variety of reasons for this, but most significantly, HTTP is used
for much more than the traditional browsing case, and encryption is not needed
for all of these uses. Making encryption MtU or MtI was seen as unlikely to
succeed because of the wide deployment of HTTP URIs.

However, since making that decision, there have been developments that
have caused the Working Group to discuss these issues again:

1. Active contributors to some browser implementations have stated that their
products will not use HTTP/2 over unencrypted connections. If this eventuates,
it will prevent wide deployment of the new protocol (i.e., it couldn't be used
with those products for HTTP URIs; only HTTPS URIs).

2. It has been reported that surveillance of HTTP traffic takes place on a
broad scale {{xkeyscore}}. While the IETF does not take a formal, moral
position on wiretapping, we do have a strongly held belief "that both
commercial development of the Internet and adequate privacy for its users
against illegal intrusion requires the wide availability of strong
cryptographic technology" {{RFC2804}}. This requirement for privacy is further
reinforced by {{RFC6973}}.

As a result, we decided to revisit the issue of how encryption is used in
HTTP/2.0 at IETF87.


# Next Steps

* Upgrade: For some flows, it may be advantageous to do an "upgrade dance" to
  the tls-relaxed protocol, a la STARTTLS. If there is sufficient interest, a
  future revision may also include a proposal for that.

* http1-tls-relaxed: If there is sufficient interest, it may also be worthwhile
  defining a HTTP/1-based tls-relaxed protocol.

  
  
# Frequently Asked Questions

## Will this make encryption mandatory in HTTP/2.0?

Not in the sense that this proposal would have it required (with a MUST) in the
specification.

What might happen, however, is that some browser implementers will take the
flexibility that this approach grants and decide to not negotiate for HTTP/2.0
without one of the encryption profiles. That means that servers would need to
implement one of the encryption-enabling profiles to interoperate using
HTTP/2.0 for HTTP URIs.


## No certificate checks? Really?

http2-tls-relaxed has the effect of relaxing certificate checks on "http://" -
but not "https://" - URIs when TLS is in use. Since TLS isn't in use for any
"http://" URIs today, there is no net loss of security, and we gain some
privacy from passive attacks.

In the future, if the certificate trust system can be improved such that it's
both more reliable and has a lower barrier to entry (e.g., see {{RFC6962}}), it
may be possible to modify or even drop the http2-tls-relaxed profile (even
before HTTP/2 ships, depending on progress there). 


## Why do this if a downgrade attack is so easy?

There are many attack scenarios (e.g., third parties in coffee shops) where
active attacks are not feasible, or much more difficult. 

Furthermore, active attacks can be more easily detected. Future infrastructure
(again, along similar lines to {{RFC6962}}) might be able to detect them and
mitigate the risk.


## What about using DNS?

Using DNS for discovery of alternate services has attractive performance
characteristics, and also avoids the "gap" vulnerability. However, it is
significantly more difficult to deploy, compared to a HTTP header.

If there is implementer interest, a future revision might include a DNS
approach.

## Doesn't Alt-Svc make it easy to hijack a Web server?

In introducing Alt-Svc, we are taking a bounded risk, in that anyone who has
access to write a response header for an origin can effectively take over the
Web site.

To mitigate this, we require the alternate server to either a) be a port on the
same hostname (as the Alternate-Protocol header from SPDY did), or if it's on
another host b) present a certificate that's valid for the origin server.

## What about using Upgrade?

While it's possible that the HTTP Upgrade header could be used in a
STARTTLS-like connection upgrade, that's more difficult to deploy with existing
infrastructure, and is constrained to upgrading the same connection, leading to
possible latency issues. Alt-Svc offers a more flexible and less intrusive
approach.

That said, if there is sufficient interest, we'll look at defining an
Upgrade-based mechanism.

## Why not 305 Use Proxy?

While it's possible to use a HTTP response code to redirect the client to an
alternate service, this would unavoidably introduce a round trip (at least)
before the new connection is established, which violates the performance focus
of HTTP/2.0.

## Will this make negotiation too "chatty"?

Putting more information into the protocol string implies that more protocols
will be created, to cover the possible space of identifiers. In turn, this
brings the risk that the negotiation phase could become bloated by a mass of
identifiers that can impact performance, much as HTTP content negotiation has
become in some cases.

There are a few factors that should mitigate this. First, as discussed above,
it's not necessary to advertise every protocol you support; only those that are
applicable to the current context need to be sent.

Moreover, we expect that the protocol mechanism will be used to negotiate
coarse-grained, backwards-incompatible changes to the protocol; this is one of
the reasons the "http2-tls-relaxed" protocol is so loosely defined, so that
future mechanisms can be easily layered upon it.

Nevertheless, the appropriate role of an ALPN protocol needs to be scrutinized
to make sure we have agreement upon what's in and out of scope for its function.
