<script>
import WebVM from '$lib/WebVM.svelte';
import * as configObj from '/config_terminal';
import { onMount } from 'svelte';
// c-drill: one block cache per published disk image. Reusing the cache of a
// previous image over a new one would corrupt the file system.
const cacheId = "blocks_" + configObj.diskImageUrl;
onMount(async () => {
	try {
		const dbs = await indexedDB.databases();
		for (const db of dbs)
			if (db.name && db.name.startsWith("blocks_") && db.name !== cacheId)
				indexedDB.deleteDatabase(db.name);
	} catch (e) { /* not supported: keep old caches */ }
});
function handleProcessCreated(processCount) {}
</script>

<WebVM configObj={configObj} processCallback={handleProcessCreated} cacheId={cacheId}>
</WebVM>
