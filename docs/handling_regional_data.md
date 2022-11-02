# How we handle regional data

At the present time we have only two regions:

 * US - doubles as a global region
 * CA - contains Canada specific data only

As our interfaces for reporting are in the US, we need to be able to view the
data from the US region. This document describes our current beliefs about what
is permitted and how we plan to act.

It is not a policy or agreement, and may be changed at any time without notice.

## General rules of handling

We have the following beliefs about Canadian data:

1. It is allowed **_at rest_** in the CA region
   * Permanently stored in a medium
   * In such a way that it remains when power is removed from the system
   * Excepting _temporary caches_ (defined below)
2. It is allowed to be **_temporarily cached_** in any region
   * In RAM
   * In temp files removed by systems automatically
   * In internet caches like Cloudflare or local browser caches
3. It is allowed to be **_processed_** in any region
   * Can be combined or have calculations performed on it
   * Mixed together with HTML to present to users etc.
4. It contains **_sensitive data_** (defined below) which is not allowed at 
   rest in any region outside of CA
   * For example where an entity could legally compel us to divulge the 
     information (e.g. the US government)
5. It contains **non-sensitive data** (defined below) which _is allowed_ at
   rest in any region

## Sensitive and non-sensitive data


These rules are intended to be read in order when a conflict appears. First 
match wins. 

### ⚠️ Information which would uniquely allow you to identify a person (**Sensitive**)

* **A persons name** 👈
* A persons address
* A persons email address 
* User chosen login / username - Can often contain their name in another form

### ✅ Anonymous information about users (_Not sensitive_)

* A user role 
* Membership or association with to an institution, group, course, 
  annotation or assignment etc.
* Boolean settings and preferences
* A domain name or email suffix
* Actions and events a user has taken (logged in, annotated etc)

### ✅ Any data created by us without incorporating external data (_Not sensitive_)

 * Opaque identifiers and ids we generate
 * An opaque generated login / username
 * Metadata like created and updated dates
 * Relationships between entities like courses, assignments, groups and 
   annotations etc.
 * Moderation status, NIPSA, deleted / archived etc.

### ✅ Aggregated counts (_Not sensitive_)

* Merged counts of users, annotations, documents, courses, assignments, events
  etc.
* Any merged counts, averages, sums or calculations
* Derived non-reversible information 
    * Like a boolean value if a condition is met 
    * e.g. a password is sensitive, but a boolean indicating the presence of a 
      password is not

### ✅ Any publicly available information (_Not sensitive_)

* Institution names
* LMS group names
* Course names
* Assignment names
* Public annotation content
* Public `h` group names
* The names of publicly annotated documents
* Content of publicly annotated documents

### ⚠️ Any data directly created by users which is not publicly available (**Sensitive**)

**Note!** This is considerably more than what we describe as "Personal 
Information" in our [Privacy Policy](https://web.hypothes.is/privacy/lms/). 
This could be a lot more than we need?

* Private annotation content
* Private `h` group names
* Names of privately annotated documents
* Content of privately annotated documents
* Secrets
* API keys
* Passwords
* Hashes or other methods which encode passwords or this type of information
* Non-boolean settings and preferences
* **Tool Consumer Instance GUID** 👈

### ⚠️ Anything which does not fit into the above (**Sensitive**)

Until a discussion is had and this definition is expanded

## Questions to answer about sensitive data

### Is the users name alone sensitive?

In general a name on it's own ("John Smith") is not sensitive, as there are 
many inviduals with the same name. 

However as we are likely to be using this data in combinations with other data, 
it's quite likely it could become personally identifiable ("John Smith who 
teachers English 101 in University of Statename").

Current decision: **Sensitive**

### Is the Tool Consumer Instance GUID sensitive?

The Tool Consumer Instance GUID (or GUID for short) is an opaque identifier 
provided by external systems to us and other 3rd parties the user chooses to 
include in their LMS. Outside of an LMS context there isn't much you can 
fruitfully find out or do with a GUID. It's not a secret, or closely guarded 
(e.g. all students can see it) but it's not _public_ information.

On one hand, many sales processes are currently centred around the GUID and 
it's likely users will request it.

On the other hand, it's not our data, and we have historically treated this as 
sensitive when it came to storing this on dev machines. A lot of the 
requirement to provide a GUID is due to it's use in the systems we are trying 
to replace. There is a good argument to be made we should not divulge it.

Current decision: **Sensitive**

## Some worked examples

### A report over users emails

* A report showing user emails 
   * **Sensitive**, because it includes emails and names
* A report showing the most common emails 
   * **Sensitive**, because it includes emails, even if other metrics are
     aggregated
* A report counting how many times emails are re-used without showing the 
  emails in question
  * _Not sensitive_, as only aggregates are used

### A report over user created data

 * A report showing a users private annotation text
    * **Sensitive**, as this is data created by the user but not publicly 
    available
 * A report showing a users public annotation text
   * _Not sensitive_, as this data is publicly available
 * A report showing the length of a users annotations
   * _Not sensitive_, as this is an aggregate over user data
 * A report showing a users opt-in or out of marketing information
   * _Not sensitive_, as it is a boolean value
 * A report showing a users API key
   * **Sensitive**, as this is data created by the user but not publicly 
     available

### How a sensitive report might be served

 * The original data is stored at rest in CA 
    * This is permitted as all data may be stored in region
 * For performance reasons this is recalculated and stored in a new form at 
   rest in CA 
   * This is permitted as all data may be stored in region
 * This new table is accessed by a system outside of CA
    * This is permitted **_so long as_** the external system does not store the
      data permanently
 * The external system performs calculations on the data
    * This is permitted as calculations on the data are permitted
 * The external system presents an HTML page to an authorized user outside of 
   CA
    * This may result in caching at the browser or Cloudflare level
    * This is permitted as temporary caching is allowed
 * The data is processed by the users browser to present it to them
     * This is permitted as calculations on the data are permitted
 * The user chooses to store the data in a spreadsheet outside of CA
    * **This is not permitted** as the data is at rest outside of the CA region
