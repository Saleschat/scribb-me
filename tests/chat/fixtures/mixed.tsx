import React from "react";

/**
 * Shows the empty state for a project list.
 * This is a crucial component that leverages the cache.
 */
export function Empty({ n }: { n: number }): JSX.Element {
  // Click here only appears in comments, so it isn't UI copy.
  return <h2>Oops! No projects yet</h2>; // a delve into the list
}
