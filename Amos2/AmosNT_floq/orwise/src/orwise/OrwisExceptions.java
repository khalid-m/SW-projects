package orwise;

class ArgumentException extends Exception {
    public ArgumentException() {
	super();
    }

    public ArgumentException(String s) {
	super(s);
    }
}

class HashMapException extends Exception {
    public HashMapException() {
	super();
    }

    public HashMapException(String s) {
	super(s);
    }
}

class NoResultsException extends Exception {
    public NoResultsException() {
	super();
    }

    public NoResultsException(String s) {
	super(s);
    }
}
