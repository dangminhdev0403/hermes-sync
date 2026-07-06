# VietSage Owner Service Catalog: Refresh After Excel Import

## Context

In `frontends/font-end-vietsage`, the owner service catalog page passes server-fetched `initialCategories` and `initialItems` into a client component. The client component then stores them in local React state so it can sort, paginate, and edit rows.

After Excel upload to:

- `/api/owner/hotels/[hotelId]/service-catalog/import`

calling `router.refresh()` alone did not update the visible table because the already-mounted client state still held the old arrays.

## Durable Fix Pattern

After a successful bulk import/sync:

1. Read the import result counts for the success dialog.
2. Explicitly refetch the list endpoints used by the table:
   - `/api/owner/hotels/${hotelId}/service-categories`
   - `/api/owner/hotels/${hotelId}/service-items`
3. Replace local `categories` and `items` state from those responses.
4. Reset pagination to page `1` if new/updated rows may otherwise be hidden.
5. Call `router.refresh()` as a secondary cache/server-props sync, not as the only UI update.

Example shape:

```tsx
async function refreshServiceCatalog() {
  const encodedHotelId = encodeURIComponent(hotelId);
  const [categoriesPage, itemsPage] = await Promise.all([
    requestInternalApi<CatalogPage<HotelServiceCategory>>(`/api/owner/hotels/${encodedHotelId}/service-categories`, { method: "GET" }),
    requestInternalApi<CatalogPage<HotelServiceItem>>(`/api/owner/hotels/${encodedHotelId}/service-items`, { method: "GET" }),
  ]);

  setCategories(categoriesPage.items);
  setItems(itemsPage.items);
  setCategoryPage(1);
  setItemPage(1);
}
```

## Pitfall

Avoid syncing prop changes into local state with a simple `useEffect(() => setState(initialProps), [initialProps])` in projects using strict React lint rules: `react-hooks/set-state-in-effect` may reject it. Prefer explicit refetch/update in the mutation success path when the data change is caused by that mutation.
