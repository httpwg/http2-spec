Submitting
==========

When you're ready to submit a new version of a draft:

0. git status  <-- all changes should be committed and pushed.

1. Double-check the year on the date element to make sure it's current.

2. Check the "Changes" section for this draft to make sure it's appropriate
   (e.g., replace "None yet" with "None").

3. make submit

4. Submit draft-ietf-httpbis-<name>-NN to https://datatracker.ietf.org/submit/

5. make clean

6. git tag draft-ietf-httpbis-<name>-NN;
   git push --tags

7. Add "Since draft-ietf-httpbis-<name>-...-NN" subsection to "Changes".

8. Add/remove any "implementation draft" notices from the abstract.
