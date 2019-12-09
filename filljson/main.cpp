#include <fstream>
#include <iostream>
using namespace std;

int main(int argc, char **argv)
{
    ifstream json(argv[1]);
    ifstream image(argv[2]);
    ofstream out(argv[3]);
    string wordToReplace(argv[4]);

    if (!json)
    {
        cerr << "ERROR: Failed to open file " << argv[1] << "\n";
        return 1;
    }

    if (!image)
    {
        cerr << "ERROR: Failed to open file " << argv[2] << "\n";
        return 1;
    }

    if (!out)
    {
        cerr << "ERROR: Failed to open file " << argv[3] << "\n";
        return 1;
    }

    string replaceWithContent(
      (istreambuf_iterator<char>(image)),
      (istreambuf_iterator<char>())
    );

    string line;
    size_t len = wordToReplace.length();

    while (getline(json, line))
    {
        while (true)
        {
            size_t pos = line.find(wordToReplace);
            if (pos != string::npos)
                line.replace(pos, len, replaceWithContent);
            else
                break;
        }

        out << line << '\n';
    }
}
