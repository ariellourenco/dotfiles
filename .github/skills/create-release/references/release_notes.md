# Release Details

- **Are there any destructive changes?** <br/>
  _State whether any existing endpoints, fields, or behaviors were removed or broken. If only deprecated (not removed), note that._

- **Change in data type of response payload?** <br/>
  _State whether any endpoint's response type changed (e.g. JSON → protobuf, shape of a model, added/removed fields). Name the endpoint
  and the new Content-Type if relevant._

- **Any unique header value is in play in this release?** <br/>
  _List any new or changed request/response headers, including auth headers, Content-Type, or custom headers._

- **Any model change?** <br/>
  _List any new or modified domain models, proto messages, or DTOs updated._

- **Any flag change?** <br/>
  _List any new, removed, or changed feature flags or configuration keys._

## Notes for the test team

After filling out the template above, write a short paragraph or bullet list that helps the test team validate the changes. Include:

- What was changed and what the expected behavior is
- Which scenarios to verify (happy path, edge cases, error cases, regression)
- Any setup or prerequisite needed before testing (e.g. specific data state, auth keys, feature flags, tool requirements)
- Any gotcha or non-obvious behavior the tester should be aware of.
