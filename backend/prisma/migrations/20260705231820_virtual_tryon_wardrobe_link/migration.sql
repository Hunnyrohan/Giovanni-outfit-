-- AlterTable
ALTER TABLE "VirtualTryOn" ADD COLUMN     "processingTime" DOUBLE PRECISION,
ADD COLUMN     "wardrobeItemId" TEXT,
ALTER COLUMN "provider" SET DEFAULT 'catvton';

-- CreateIndex
CREATE INDEX "VirtualTryOn_wardrobeItemId_idx" ON "VirtualTryOn"("wardrobeItemId");

-- AddForeignKey
ALTER TABLE "VirtualTryOn" ADD CONSTRAINT "VirtualTryOn_wardrobeItemId_fkey" FOREIGN KEY ("wardrobeItemId") REFERENCES "WardrobeItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;
