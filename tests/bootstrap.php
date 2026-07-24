<?php
// Pure-logic unit test bootstrap. includes/db.php connects lazily (only when
// db() is actually called), so pulling in functions.php here does NOT require
// a live database — as long as the tests themselves never call anything that
// touches db() (getSetting(), auditLog(), etc. are integration-test territory,
// not covered by this suite).
require_once __DIR__ . '/../includes/functions.php';
