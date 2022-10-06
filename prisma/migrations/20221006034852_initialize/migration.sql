-- CreateTable
CREATE TABLE "Quote" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "timestamp" TEXT NOT NULL DEFAULT (strftime('%s', 'now')),
    "quotee" TEXT NOT NULL,
    "quoter" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "year" TEXT NOT NULL
);
