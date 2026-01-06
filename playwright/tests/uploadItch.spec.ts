import { test, expect } from "@playwright/test";

const itchURL: string = "https://itch.io/login";
const gamedashboard: string = process.env.ITCHURL!;
const user: string = process.env.ITCHUSERNAME!;
const pass: string = process.env.ITCHPASSWORD!;
const fileNameWeb: string = process.env.PROJECTNAME + "Web.zip";
const fileNameLinux: string = process.env.PROJECTNAME + "Linux.zip";
const fileNameMacOS: string = process.env.PROJECTNAME + "MacOS.zip";
const fileNameWindows: string = process.env.PROJECTNAME + "Windows.zip";
const gameZipWeb: string = `../../build/${fileNameWeb}`;
const gameZipLinux: string = `../../build/${fileNameLinux}`;
const gameZipMacOS: string = `../../build/${fileNameMacOS}`;
const gameZipWindows: string = `../../build/${fileNameWindows}`;

test("upload to itch.io", async ({ page }) => {
	console.log(user);
	if (gamedashboard) {
		console.log("Logging in to itch.io...");
		await page.goto(itchURL);

		await page.getByLabel("Username or email").fill(user);
		await page.getByLabel("Password").fill(pass);
		await page.getByRole("button", { name: "Log in", exact: true }).click();
		await page.goto(gamedashboard);


		if (process.env.WEBBUILD == "true") {
			await test.step("Upload Web", async () => {
				await uploadItch(fileNameWeb, gameZipWeb);
			});
		}


		if (process.env.LINUXBUILD == "true") {
			await test.step("Upload Linux", async () => {
				await uploadItch(fileNameLinux, gameZipLinux);
			});
		}


		if (process.env.MACOSBUILD == "true") {
			await test.step("Upload MacOS", async () => {
				await uploadItch(fileNameMacOS, gameZipMacOS);
			});
		}


		if (process.env.WINDOWSBUILD == "true") {
			await test.step("Upload Windows", async () => {
				await uploadItch(fileNameWindows, gameZipWindows);
			});
		}

		await page.locator('div').filter({ hasText: /^SaveView pageDelete game$/ }).getByRole('button').click();
		await page.close();







		async function uploadItch(fileName: string, zipDir: string) {
			// Delete before uploading
			if (await page.getByText(`More…Delete file${fileName}`).getByRole('button', { name: 'Delete file' }).isVisible()) {
				console.log("Deleting existing file...");
				await page.getByText(`More…Delete file${fileName}`).getByRole('button', { name: 'Delete file' }).click();
				await page.getByLabel('I confirm I want to delete').check();
				await page.locator('#lightbox_container').getByRole('button', { name: 'Delete' }).click();
			}

			// Start waiting for file chooser before clicking.
			await console.log(`Uploading file: ${fileName}`);
			const fileChooserPromise = page.waitForEvent("filechooser");
			await page.getByRole("button", { name: "Upload files" }).click();
			const fileChooser = await fileChooserPromise;
			await fileChooser.setFiles(zipDir);


			if (fileName === fileNameWeb) {
				console.log(`Uploading ${fileName}`)
				await page.getByText(`More…Delete file${fileName}`).getByRole('checkbox', { name: 'This file will be played in the browser', exact: true }).check({ timeout: 10000 });
				await expect(page.getByText(`More…Delete file${fileName}`).getByRole('checkbox', { name: 'This file will be played in the browser', exact: true }).isChecked()).toBeTruthy();
			}
			else if (fileName === fileNameLinux) {
				console.log(`Uploading ${fileName}`)
				await page.getByText(`More…Delete file${fileName}`).locator('input[name*="p_linux"]').check();
			}
			else if (fileName === fileNameMacOS) {
				console.log(`Uploading ${fileName}`)
				await page.getByText(`More…Delete file${fileName}`).locator('input[name*="p_osx"]').check();
			}
			else if (fileName === fileNameWindows) {
				console.log(`Uploading ${fileName}`)
				await page.getByText(`More…Delete file${fileName}`).locator('input[name*="p_windows"]').check();
			}
			await expect(page.locator('div').filter({ hasText: new RegExp(`^${fileName} · Success$`) }).locator('span')).toBeVisible();
			await console.log(`File ${fileName} uploaded successfully.`);
		}

	}
	else {
		console.log("Environment variables are not set. Skipping upload.");
	}
});

