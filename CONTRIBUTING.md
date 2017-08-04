## How to contribute (No GitHub knowledge required):

### Feature request, bug reporst and general comments
An easy but still very helpful way to provide feedback on this resource is to create an issue in GitHub. You can read issues submitted by other users or create a new issue [here](https://github.com/worldbank/ietoolkit). While the word issue has a negative connotation outside GitHub, a GitHub-issue can be used for any kind of feedback. Even a question on how to use the resource.

If you have an idea for a new template or exercise, or a specific need that isn't covered here, creating an issue is a great tool for suggesting that. Please read already existing issues to check whether someone else has made the same suggestion or reported the same error before creating a new issue. You can use the search bar in case the number of issues is large.

## How to contribute using Github:

**Important:** Do not include pdf-files in any pull request apart from when merging to the _Master_ branch. Pdf-files are of binary type which as not shared efficeintly over GitHub. Instead, include only the LaTeX code when merging across branches, and then compile the merged LaTeX file to a pdf file locally on your computer only.

### Opening and organizaing a new issue
1. Open issues for all edits you make that are not trivial, such as typos in text etc.
1. If your issue is related to any of the projects we have ([see projects here](https://github.com/worldbank/DIME-LaTeX-Templates/projects)) then click on that project, then click _*Add cards*_ and drag your issue to the todo column
1. Assign this issue to yourself or someone else, or let someone else assign themself.

### Working on a solution to an issue
1. Assign yourself if you have not already done so. 
1. If the issue is sorted under a project (if it is it will show in the comment thread for that issue), then go to that project and drag the issue to the _Started_ column.
1. Unless the solution is simple, create a new brach of the develop branch and name it after the issue. Include the issue number and a word or two describing the issue. (If the solution is simple then make your change directly to the _develop_ branch and skip to step 8 when you are done.)
1. If you at any point need help with the solution, ask for that in the comment thread for this issue. Tag one of the admins (or both) by writing `@luizaandrade` or `@mrimal` anywhere in your comment to make sure someone is notified.
1. When you are done create a pull request from your branch to the develop branch.
1. If your issue is sorted under a project, then go to that project and drag the issue to the _Done - Waiting to be merged to develop-branch_ column.
1. If you feel confident in your solution you can yourself merge your branch to the _develop_ branch. 
1. If you confirm your own pull request (or made the change directly to the _develop_ branch) and your issue is part of a project, then drag your issue to the column _Done - Waiting to be merged to master-branch_ 
1. Only admin can merge to the master branch, and only then will the issue be closed.
