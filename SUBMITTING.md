Submitting
==========

When you're ready to submit a new version of draft-ietf-httpbis-http-NN:

0. git status  <-- all changes should be committed and pushed.

1. Double-check the year on the date element to make sure it's current.

2. Check the "Changes" section for this draft to make sure it's appropriate
   (e.g., replace "None yet" with "None").

3. make -e submit

4. Submit draft-ietf-httpbis-http-NN to https://datatracker.ietf.org/submit/

5. make clean

6. git tag draft-ietf-httpbis-http-NN
   git push --tags origin master

7. Add "Since draft-ietf-httpbis-http2-...-NN" subsection to "Changes".
