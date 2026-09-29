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
			// names look like "cjFS_/blocks_<image>/": drop the caches of older images
			if (db.name && db.name.includes("blocks_") && !db.name.includes(cacheId + "/"))
				indexedDB.deleteDatabase(db.name);
	} catch (e) { /* not supported: keep old caches */ }
});
function handleProcessCreated(processCount) {}
</script>

<WebVM configObj={configObj} processCallback={handleProcessCreated} cacheId={cacheId}>
</WebVM>
